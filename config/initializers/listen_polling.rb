if Rails.env.development?
  begin
    require "listen"
    original_listen_to = Listen.method(:to)
    Listen.define_singleton_method(:to) do |*paths, **options, &block|
      original_listen_to.call(*paths, **options.merge(force_polling: true), &block)
    end
  rescue LoadError
    # listen gem not in load path (BUNDLE_WITHOUT=development) — polling disabled
  end
end
