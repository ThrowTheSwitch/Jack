require 'fileutils'
require 'erb'

if 0 == ARGV.length || "-h" == ARGV[0] || "--help" == ARGV[0]
  puts "Usage: #{$0} name path/to/new/package copy/files/from [relative/bin/dir]"
  exit(1)
end

the_name = ARGV[0]
path_to_package = ARGV[1]
copy_files_from = ARGV[2]
bin_dir = ARGV[3] || File.basename(copy_files_from)
rel_bin_dir = File.join("..", "files", bin_dir)

def generate_file(input_file, output_file, data)
    File.open(output_file, "w") do |f|
      erb = ERB.new(File.read(input_file), 0, "%<>")
      f.write(erb.result(binding()))
    end
end

skeleton = File.join(File.dirname(__FILE__), "skeleton")

package_files = File.join(path_to_package, "files")
package_lib   = File.join(path_to_package, "lib")

FileUtils.mkdir_p package_files
FileUtils.mkdir_p package_lib

FileUtils.cp File.join(skeleton, "Gemfile"), path_to_package
FileUtils.cp File.join(skeleton, "VERSION"), path_to_package

data = {
    :name        => the_name,
    :summary     => "GemJacked #{the_name}",
    :description => "A gem to control the configuration of #{the_name}.",
    :rel_bin_dir => rel_bin_dir
  }

generate_file(
  File.join(skeleton, "Rakefile.erb"),
  File.join(path_to_package, "Rakefile"),
  data)

generate_file(
  File.join(skeleton, "lib", "template.rb.erb"),
  File.join(package_lib, "#{the_name.downcase}.rb"),
  data)

FileUtils.cp_r copy_files_from, package_files

puts "built #{the_name} from skeleton"
