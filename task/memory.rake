# Cheap way of benchmarking the memory usage of various parts of the FFI
# binding.
def benchmark_block(amount = 10000)
  require File.expand_path('../../lib/ffi/aspell', __FILE__)

  start_mem = `ps -o rss= #{Process.pid}`.to_f

  amount.times { yield }

  mem = ((`ps -o rss= #{Process.pid}`.to_f - start_mem) / 1024).round(2)

  puts "Memory increase in Megabytes: #{mem} MB"
end

namespace :memory do
  memory = proc { `ps -o rss= #{Process.pid}`.to_i }

  desc 'Show memory usage of Aspell.speller_new'
  task :speller, [:amount] do |task, args|
    args.with_defaults(:amount => 10000)

    benchmark_block(args.amount) do
      speller = FFI::Aspell.speller_new(FFI::Aspell.config_new)

      FFI::Aspell.speller_delete(speller)
    end
  end

  desc 'Show memory usage of Speller#correct?'
  task :correct, [:amount] do |task, args|
    args.with_defaults(:amount => 10000)

    benchmark_block(args.amount) do
      speller = FFI::Aspell::Speller.new

      speller.correct?('cookie')
    end
  end

  desc 'Show memory usage of Speller#suggestions'
  task :suggestions, [:amount] do |task, args|
    args.with_defaults(:amount => 10000)

    benchmark_block(args.amount) do
      speller = FFI::Aspell::Speller.new

      speller.suggestions('cookei')
    end
  end
end
