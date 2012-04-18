namespace :memory do
  memory = proc { `ps -o rss= #{Process.pid}`.to_i }

  desc 'Show memory usage of Aspell.speller_new'
  task :speller, [:amount] do |task, args|
    args.with_defaults(:amount => 10000)

    require File.expand_path('../../lib/ffi/aspell', __FILE__)

    start_mem = memory.call

    args.amount.times do
      speller = FFI::Aspell.speller_new(FFI::Aspell.config_new)

      FFI::Aspell.speller_delete(speller)
    end

    mem = (memory.call - start_mem) / 1024

    puts "Memory usage in Megabytes: #{mem} MB"
  end

  desc 'Show memory usage of Speller#correct?'
  task :correct, [:amount] do |task, args|
    args.with_defaults(:amount => 10000)

    require File.expand_path('../../lib/ffi/aspell', __FILE__)

    start_mem = memory.call

    args.amount.times do
      speller = FFI::Aspell::Speller.new

      speller.correct?('cookie')
    end

    mem = (memory.call - start_mem) / 1024

    puts "Memory usage in Megabytes: #{mem} MB"
  end
end
