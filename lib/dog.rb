class Dog
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize (id: nil, name: nil, breed: nil)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL  
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
     SQL
      
    DB[:conn].execute(sql)
  end
    
  def self.drop_table
    sql = <<-SQL 
    DROP TABLE IF EXISTS dogs
    SQL
      
    DB[:conn].execute(sql)
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
      
  def self.create(hash)
    new_dog = Dog.new
      hash.each do |k,v| 
      new_dog.send("#{k}=", v)
    end
    new_dog.save
  end
      
  def self.new_from_db(row)
    self.new(id: row[0] , name: row[1] , breed: row[2])
  end
        
      
  def self.find_by_id (id)
    DB[:conn].results_as_hash =true
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql , id)[0]
    self.new(name: result["name"] , name: result["breed"] , id: result["id"])
  end
  
  def self.find_by_name(name)
    DB[:conn].results_as_hash =false
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql , name)[0]
    self.new(id: result[0] , name: result[1] , breed: result[2])
  end
    
    
  def self.find_or_create_by (hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql , hash[:name] , hash[:breed])

    if !result.empty?
      self.find_by_id(result[0]["id"])
    else
      self.create(hash)
    end
  end
  
  
  def update
    sql = "UPDATE dogs SET name = ? , breed = ? WHERE id = ?"
    DB[:conn].execute(sql , self.name , self.breed , self.id)
  end
  
end
    
        
            
          
