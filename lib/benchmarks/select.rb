Benchmark.bmbm do |bm|
      Interaction.connection.clear_query_cache
      bm.report("select") do
        Interaction.active.select(:id)
      end
    end


Benchmark.bmbm do |bm|
      Interaction.connection.clear_query_cache
      bm.report("*") do
        Interaction.active.map(&:id)
      end
    end
