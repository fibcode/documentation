# Patch dynamic_form to work with Rails 6
# Based on https://github.com/Prista1/dynamic_form/commit/b74b59d7eb3bc9ed609380aea8a41159918d501b
module ActiveModel
  class Errors
    def full_messages
      full_messages = []

      each do |attribute, messages|
        messages = Array.wrap(messages)
        next if messages.empty?

        if attribute == :base
          messages.each {|m| full_messages << m }
        else
          attr_name = attribute.to_s.gsub('.', '_').humanize
          attr_name = @base.class.human_attribute_name(attribute, :default => attr_name)
          options = { :default => "%{attribute} %{message}", :attribute => attr_name }

          messages.each do |m|
            if m =~ /^\^/
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", **options.merge(:message => m[1..-1]))
            elsif m.is_a? Proc
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", **options.merge(:message => m.call(@base)))
            else
              full_messages << I18n.t(:"errors.format", **options.merge(:message => m))
            end
          end
        end
      end

      full_messages
    end
  end
end
