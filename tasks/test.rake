require 'rake/testtask'

Rake::TestTask.new do |t|
 t.libs.push 'spec'
 t.libs.push 'test'
 t.pattern = 'spec/**/*_{spec,test}.rb'
 t.pattern = 'test/**/*_{spec,test}.rb'
end
