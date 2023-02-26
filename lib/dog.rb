class Dog
    #has an id that defaults to `nil` on initialization'
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def attributes(name:, breed:)
    end

    #.create_table"-it 'creates the dogs table in the database'
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    #.drop_table"-it 'drops the dogs table from the database'
    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    #"#save"- it 'returns an instance of the dog class'
    def save
        sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    #.create" do it 'create a new dog object and uses the #save method to save that dog to the database'do
    def self.create name:, breed;
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    #.new_from_db'it 'creates an instance with corresponding attribute values'
    def self.new_from_db row
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    #.all'-it 'returns an array of Dog instances for all records in the dogs table'
    def self.all
        DB[:conn].execute("SELECT * FROM dogs").collect do |row|
            Dog.new_from_db row
        end
    end

    #.find_by_name' it 'returns an instance of dog that matches the name from the DB'
    def self.find_by_name name
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
        DB[:conn].exeute(sql,name).map {|row| self.new_from_db(row)}.first
    end

    #
    def self.find id
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].exeute(sql,id).collect {|row| self.new_from_db(row)}.first
    end
end
