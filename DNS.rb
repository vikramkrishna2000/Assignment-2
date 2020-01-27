def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

# ..
# ..
# FILL YOUR CODE HERE
# ..
# ..

def parse_dns(dns_raw)
  dns_records = {}
  dns_raw.each do |rec|
    rec=rec.chomp
    unless rec[0] == "#" || rec.empty?
      records = rec.split(/,/)
      records = records.map {|recd| recd.strip()}
      unless dns_records.has_key?(records[0])
        dns_records.store(records[0],[[records[1],records[2]]])
      else
        dns_records[records[0]].push([records[1],records[2]])
      end
    end
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  for dom in dns_records["A"]
    if (domain == dom[0])
      lookup_chain.push(dom[1])
      return lookup_chain
    end
  end
  for dom in dns_records["CNAME"]
    if (domain == dom[0])
      lookup_chain.push(dom[1])
      return resolve(dns_records, lookup_chain, dom[1])
    end
  end
  lookup_chain.push("Further mapping not found in Zone file")
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
