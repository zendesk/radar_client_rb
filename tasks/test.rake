require 'rake/testtask'

Rake::TestTask.new do |t|
 t.libs.push 'spec'
 t.libs.push 'test'
 t.pattern = '{spec,test}/**/*_{spec,test}.rb'
end
