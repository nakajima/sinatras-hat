require 'metaid'

class Object
  def tap
    yield self
    self
  end
  
  def with(hash)
    hash.each do |key, value|
      meta_def(key) { hash[key] } unless respond_to?(key)
      meta_def("#{key}=") { |v| hash[key] = v } unless respond_to?("#{key}=")
    end
    
    return unless block_given?

    result = yield

    hash.each do |key, value|
      meta_eval { remove_method(key) }
      meta_eval { remove_method("#{key}=") }
    end

    result
  end

  module InstanceExecHelper; end
  include InstanceExecHelper
  def instance_exec(*args, &block)
    begin
      old_critical, Thread.critical = Thread.critical, true
      n = 0
      n += 1 while respond_to?(mname="__instance_exec#{n}")
      InstanceExecHelper.module_eval{ define_method(mname, &block) }
    ensure
      Thread.critical = old_critical
    end
    begin
      ret = send(mname, *args)
    ensure
      InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
    end
    ret
  end
end