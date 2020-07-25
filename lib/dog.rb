# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]

require_relative "../config/environment.rb"

class Dog


  attr_accessor :name, :breed, :id
  
  
  def initialize(attrHash)
    attrHash.each {|k,v|
        self.send("#{k}=", v)
    }
    
  end



  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end 

  def save
    if self.id  
      self.update
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
    
  end 

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
          breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attrHash)
    dog = Dog.new(attrHash)
    dog.save
    dog
  end 

  def self.new_from_db(row)
    dog = Dog.new({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(attrHash)
    dog = self.find_by_name(attrHash[:name])
    if dog.name == attrHash[:name] && dog.breed == attrHash[:breed]
        dog 
    else
        dog = self.create(attrHash)
    end
    dog
  end
end