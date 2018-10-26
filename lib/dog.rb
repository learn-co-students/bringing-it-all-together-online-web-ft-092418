class Dog
attr_accessor :name , :breed
attr_reader :id

def initialize(name: nil , breed: nil , id: nil)
  @name = name
  @breed = breed
  @id = id

end


def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT ,
    breed TEXT
  )
  SQL
  DB[:conn].execute(sql)

end

def self.drop_table
  sql = <<-SQL
  DROP TABLE  dogs
  SQL
  DB[:conn].execute(sql)

end

def update
  sql = "UPDATE dogs SET name = ? , breed = ? WHERE id = ?"
  DB[:conn].execute(sql , self.name , self.breed , self.id)

end

def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name , breed)
      VALUES ( ? , ? )
    SQL
    DB[:conn].execute(sql , self.name , self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
end

 def self.create (dog_hash)
      dog = self.new()
      dog_hash.each do |k ,v|
        dog.send("#{k}=" , v)
      end
      dog.save
 end

 def self.find_by_id (id)
   DB[:conn].results_as_hash =true
   sql = "SELECT * FROM dogs WHERE id = ?"
   result = DB[:conn].execute(sql , id)[0]
   self.new(name: result["name"] , name: result["breed"] , id: result["id"])

 end

def self.find_or_create_by (dog_hash)
  sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
  result = DB[:conn].execute(sql , dog_hash[:name] , dog_hash[:breed])

  if !result.empty?
    self.find_by_id(result[0]["id"])
  else
    self.create(dog_hash)
  end
end


def self.new_from_db(row)
  self.new(id: row[0] , name: row[1] , breed: row[2])
end


def self.find_by_name(name)
  DB[:conn].results_as_hash = false
  sql = "SELECT * FROM dogs WHERE name = ?"
  row = DB[:conn].execute(sql , name)[0]
  #binding.pry
  self.new(id: row[0] , name: row[1] , breed: row[2])


end
end
