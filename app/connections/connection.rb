class Connection
  ["execute", "values", "prepare_elements", "get_data"].each do |action|
    define_method("#{action}") do |argument|
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}' on #{argument}"
    end
  end
end
