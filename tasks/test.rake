require 'rake/testtask'

Rake::TestTask.new do |t|
 t.libs.push 'spec'
 t.pattern = 'spec/**/*_{spec,test}.rb'
end
