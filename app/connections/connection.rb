class Connection
  %w[execute values prepare_elements get_data connect close get_param].each do |action|
    define_method(action) do |*arguments|
      raise NotImplementedError, "#{self.class} has not implemented method '#{action}'"
    end
  end
end
