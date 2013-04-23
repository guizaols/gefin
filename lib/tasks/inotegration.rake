namespace :inotegration do

  desc "Run all build test from Inotegration"

  task :all do
    require 'flog'
    require 'flay'
    require 'roodi'
    require 'reek'

    folder_names_to_analyse = ['app']
    files_to_analyse = 'app/**/*.rb'
    unless Dir.glob('lib/*.rb').empty?
      folder_names_to_analyse << 'lib'
      files_to_analyse += ' lib/*.rb'
    end

class Flay
  def report_string prune = nil
    out = ""
    out += "Total score (smaller is better) = #{self.total}\n"

    count = 0
    masses.sort_by { |h,m| [-m, hashes[h].first.file] }.each do |hash, mass|
      nodes = hashes[hash]
      next unless nodes.first.first == prune if prune
      out += "\n"

      same = identical[hash]
      node = nodes.first
      n = nodes.size
      match, bonus = if same then
                       ["IDENTICAL", "*#{n}"]
                     else
                       ["Similar",   ""]
                     end

      count += 1
      out += "%d) %s code found in %p (score %s = %d)\n" %
        [count, match, node.first, bonus, mass]

      nodes.each_with_index do |node, i|
        if option[:verbose] then
          c = (?A + i).chr
          out += "  #{c}: #{node.file}:#{node.line}\n"
        else
          out += "  #{node.file}:#{node.line}\n"
        end
      end

      if option[:verbose] then
        out += "\m"
        r2r = Ruby2Ruby.new
        out += n_way_diff(*nodes.map { |s| r2r.process(s.deep_clone) })
        out += "\n"
      end
    end
    out
  end
end


    inotegration_config = YAML::load_file(RAILS_ROOT + '/config/inotegration.yml')
    passed = []
    failed = {}

    
      
      begin
              str = `rake spec RAILS_ENV=test`
      if !str.include? 'Finished'
        nil
      elsif str.include?('0 failures')
        str
      else
        raise str
      end

        passed << 'Spec'
      rescue Exception => e
        failed['Spec'] = e.message
      end
    
      
      begin
              flog = Flog.new
      flog.flog_files folder_names_to_analyse
      threshold = inotegration_config['MaximumFlogComplexity'].to_i

      bad_methods = flog.totals.select do |name, score|
        score > threshold
      end

      if bad_methods.empty?
        "No method found with complexity > #{threshold}.
To change this limit, check README file."
      else
        bad_methods = bad_methods.sort { |a,b| a[1] <=> b[1] }.collect do |name, score|
          "%8.1f: %s" % [score, name]
        end
        raise "#{bad_methods.length} method(s) with complexity > #{threshold}:
#{bad_methods.join("
")}.
To change this limit, check README file."
      end

        passed << 'Code Complexity (Flog)'
      rescue Exception => e
        failed['Code Complexity (Flog)'] = e.message
      end
    
      
      begin
              if inotegration_config['ReekConfig'].blank?
        File.delete 'site.reek' if File.exists? 'site.reek'
      else
        File.open 'site.reek', 'w' do |f|
          f.puts inotegration_config['ReekConfig'].to_yaml
        end
      end
      begin
        str = `reek #{files_to_analyse}`
        if str.blank?
          "No bad smells found in this project"
        else
          raise str
        end
      ensure
        File.delete 'site.reek' if File.exists? 'site.reek'
      end

        passed << 'Code Quality (Reek)'
      rescue Exception => e
        failed['Code Quality (Reek)'] = e.message
      end
    
      
      begin
              str = `rake test:functionals`
      if !str.include? 'Finished'
        nil
      elsif str.include?('0 failures, 0 errors')
        str
      else
        raise str
      end

        passed << 'Functional Tests'
      rescue Exception => e
        failed['Functional Tests'] = e.message
      end
    
      
      begin
              if inotegration_config['RoodiConfig'].blank?
        str = `roodi app/**/*.rb lib/**/*.rb`
      else
        File.open 'tmp/roodi.yml', 'w' do |f|
          f.puts inotegration_config['RoodiConfig'].to_yaml
        end
        str = `roodi -config=tmp/roodi.yml #{files_to_analyse}`
      end
      if str.include?('Found 0 errors')
        str
      else
        raise str
      end

        passed << 'Code Quality (Roodi)'
      rescue Exception => e
        failed['Code Quality (Roodi)'] = e.message
      end
    
      
      begin
              str = `rake test:units`
      if !str.include? 'Finished'
        nil
      elsif str.include?('0 failures, 0 errors')
        str
      else
        raise str
      end

        passed << 'Unit Tests'
      rescue Exception => e
        failed['Unit Tests'] = e.message
      end
    
      
      begin
              threshold = inotegration_config['MaximumFlayThreshold'].to_i
      flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
      flay.process(*Flay.expand_dirs_to_files(folder_names_to_analyse))

      if flay.masses.empty?
        "No code block with duplication > #{threshold}.
To change this limit, check README file."
      else
        raise "#{flay.masses.size} code block(s) with duplicated data with threshold #{threshold}:
#{flay.report_string}.
To change this limit, check README file."
      end

        passed << 'Code Duplication'
      rescue Exception => e
        failed['Code Duplication'] = e.message
      end
    

    failed.each do |name, result|
      puts "FAILED: #{name}:\n#{result}"
    end
    puts "#{failed.length} FAILED: #{failed.keys.join ', '}\n\n"
    puts "#{failed.length} PASSED: #{passed.join ', '}"
  end
end
