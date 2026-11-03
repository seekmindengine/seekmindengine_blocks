#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(__dir__).parent.expand_path
MODULE_DIR = ROOT.join("docs/modules")
REQUIRED_SECTIONS = [
  "概览",
  "模块信息",
  "何时使用",
  "输入与输出",
  "参数",
  "工作原理",
  "快速示例",
  "性能与部署",
  "故障排查",
  "相关 Block"
].freeze
FORBIDDEN_TERMS = Regexp.union(
  ["Open", "Ensonic"].join
)

# Expand only explicitly grouped labels; never silently ignore unknown parameters.
def expand_label(label, defined_labels)
  if (match = label.match(/\ALine (\d+)\.\.(\d+) (.+)\z/))
    (match[1].to_i..match[2].to_i).map { |index| "Line #{index} #{match[3]}" }
  elsif (match = label.match(/\A(Ch|Mb)X: (.+)\z/))
    pattern = /\A#{match[1]}\d+: #{Regexp.escape(match[2])}\z/
    matches = defined_labels.select { |candidate| candidate.match?(pattern) }
    matches.empty? ? [label] : matches
  else
    [label]
  end
end

errors = []
module_files = MODULE_DIR.glob("*.md").sort
definitions_root = nil

if ARGV.any?
  unless ARGV.length == 2 && ARGV[0] == "--definitions"
    warn "用法: ruby scripts/validate_docs.rb [--definitions /path/to/blocks]"
    exit 2
  end

  definitions_root = Pathname.new(ARGV[1]).expand_path
  unless definitions_root.directory?
    warn "模块定义目录不存在：#{definitions_root}"
    exit 2
  end
end

readme = ROOT.join("README.md").read
indexed_module_paths = readme.scan(/\]\((docs\/modules\/[^)#]+\.md)(?:#[^)]*)?\)/).flatten.uniq
module_paths = module_files.map { |path| path.relative_path_from(ROOT).to_s }
(module_paths - indexed_module_paths).each do |path|
  errors << "README.md: Block 目录缺少模块页链接：#{path}"
end

module_files.each do |path|
  text = path.read
  relative = path.relative_path_from(ROOT)

  REQUIRED_SECTIONS.each do |section|
    errors << "#{relative}: 缺少二级章节“#{section}”" unless text.match?(/^## #{Regexp.escape(section)}$/)
  end

  errors << "#{relative}: 代码围栏未成对闭合" if text.scan(/^```/).length.odd?
  errors << "#{relative}: 含有已停用的产品或编辑器术语" if text.match?(FORBIDDEN_TERMS)
  errors << "#{relative}: 端口表暴露了内部模板表达式" if text.match?(/^\| (?:输入|输出).*(?:\$|@)\{/)
end

ROOT.glob("**/*.md").each do |path|
  text = path.read
  relative = path.relative_path_from(ROOT)

  framework_term = Regexp.new(["gnu", "radio"].join("[ _-]*"), Regexp::IGNORECASE)
  if path != ROOT.join("README.md") && text.match?(framework_term)
    errors << "#{relative}: 底层框架名称仅允许出现在 README.md"
  end

  errors << "#{relative}: 代码围栏未成对闭合" if text.scan(/^```/).length.odd?
  errors << "#{relative}: 含有已停用的产品或编辑器术语" if text.match?(FORBIDDEN_TERMS)

  text.scan(/!?\[[^\]]*\]\(([^)]+)\)/).flatten.each do |target|
    target = target.split(/\s+['\"]/, 2).first
    next if target.empty? || target.start_with?("#")
    next if target.match?(%r{\A(?:https?|mailto):}i)

    file_part = target.split("#", 2).first
    linked_path = path.dirname.join(file_part).cleanpath
    errors << "#{relative}: 本地链接不存在：#{target}" unless linked_path.exist?
  end
end

if definitions_root
  upstream_by_id = {}

  definitions_root.glob("**/*.block.yml").each do |path|
    text = path.read
    block_id = text[/^id:\s*([^\s#]+)\s*$/, 1]
    upstream_by_id[block_id] = [path, text] if block_id
  end

  matched_count = 0
  module_files.each do |path|
    text = path.read
    block_id = text[/^\| Block ID \| `([^`]+)` \|$/, 1]
    unless block_id
      errors << "#{path.relative_path_from(ROOT)}: 缺少 Block ID"
      next
    end

    upstream = upstream_by_id[block_id]
    unless upstream
      errors << "#{path.relative_path_from(ROOT)}: 未找到 Block ID #{block_id} 的模块定义"
      next
    end
    matched_count += 1

    upstream_path, upstream_text = upstream
    parameter_yaml = upstream_text[/^parameters:\n(.*?)(?=^[a-z_]+:|\z)/m, 1].to_s
    upstream_parameters = {}
    current_parameter = nil
    parameter_yaml.each_line do |line|
      if (match = line.match(/^\s*-\s+id:\s*([^\s#]+)/))
        current_parameter = match[1]
      elsif current_parameter && (match = line.match(/^\s+label:\s*([^\n]+)$/))
        label = match[1].strip.sub(/\A(['"])(.*)\1\z/, "\\2")
        upstream_parameters[current_parameter] = label
        current_parameter = nil
      end
    end
    upstream_labels = upstream_parameters.values

    parameter_docs = text[/^## 参数\n(.*?)(?=^## |\z)/m, 1].to_s
    documented_labels = parameter_docs.scan(/^\| \*\*([^*]+)\*\* \|/).flatten
    expanded_labels = documented_labels.flat_map { |label| expand_label(label, upstream_labels) }

    extra_labels = expanded_labels - upstream_labels
    missing_labels = upstream_labels - expanded_labels
    extra_labels.each do |label|
      relative_upstream = upstream_path.relative_path_from(definitions_root)
      errors << "#{path.relative_path_from(ROOT)}: 参数“#{label}”不在定义 #{relative_upstream} 中"
    end
    missing_labels.each do |label|
      relative_upstream = upstream_path.relative_path_from(definitions_root)
      errors << "#{path.relative_path_from(ROOT)}: 缺少定义参数“#{label}”（#{relative_upstream}）"
    end

    python_templates = upstream_text[/^templates:\n(.*?)(?=^cpp_templates:|^documentation:|^file_format:|\z)/m, 1].to_s
    callback_yaml = python_templates[/^( +)callbacks:\n(.*?)(?=^\1[a-z_]+:|\z)/m, 2].to_s
    runtime_rows = {}
    parameter_docs.scan(/^\| \*\*([^*]+)\*\* \|.*?\|\s*([^|\s]+)\s*\|$/).each do |label, value|
      expand_label(label, upstream_labels).each { |expanded| runtime_rows[expanded] = value }
    end
    upstream_parameters.each do |parameter_id, label|
      next unless callback_yaml.match?(/\$\{\s*#{Regexp.escape(parameter_id)}\s*\}/)
      next unless runtime_rows[label]&.include?("✗")

      errors << "#{path.relative_path_from(ROOT)}: 参数“#{label}”存在定义中的 Python callback，不应标为不可运行时调整"
    end

    expected_message_ports = []
    { "inputs" => "输入", "outputs" => "输出" }.each do |yaml_key, direction|
      port_yaml = upstream_text[/^#{yaml_key}:\n(.*?)(?=^[a-z_]+:|\z)/m, 1].to_s
      port_yaml.scan(/^ *-\s+domain:\s*message\n(.*?)(?=^ *-\s+(?:domain|label|id):|\z)/m).flatten.each do |entry|
        port_id = entry[/^\s+id:\s*['"]?([^\s'"]+)/, 1]
        expected_message_ports << [direction, port_id] if port_id
      end
    end

    io_docs = text[/^## 输入与输出\n(.*?)(?=^## |\z)/m, 1].to_s
    documented_message_ports = io_docs.scan(/^\| (输入|输出) \| `([^`]+)` \| 消息 \|/)
    (expected_message_ports - documented_message_ports).each do |direction, port_id|
      errors << "#{path.relative_path_from(ROOT)}: 缺少定义中的#{direction}消息端口“#{port_id}”"
    end
    (documented_message_ports - expected_message_ports).each do |direction, port_id|
      errors << "#{path.relative_path_from(ROOT)}: 文档#{direction}消息端口“#{port_id}”不在模块静态定义中"
    end
  end

  puts "模块定义对照完成：#{matched_count}/#{module_files.length} 个模块已匹配。"
end

if errors.empty?
  puts "文档校验通过：模块索引、结构、链接、术语和代码围栏均正常。"
  exit 0
end

warn "文档校验失败（#{errors.length} 项）："
errors.each { |error| warn "- #{error}" }
exit 1
