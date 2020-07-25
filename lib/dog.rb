class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    hash.each {|k,v| self.send("#{k}=", v)}
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.create(name: name, breed: breed)
    self.new({name: name, breed: breed})
    self.save
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
  end

  def update
    #binding.pry
    DB[:conn].execute("UPDATE dogs SET id = ?, name = ?, breed = ?", self.id, self.name, self.breed)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
    self
  end

  def self.create(hash)
    self.new(hash).tap{|dog| dog.save}
  end

  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute("SELECT id FROM dogs WHERE id = ?", id)[0])
  end

  def self.find_or_create_by(hash)
  #  binding.pry
    my_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    #binding.pry
    if my_dog != []
      self.find_by_id(my_dog[0][0])
    else
      self.create(hash)
    end
  end
end
