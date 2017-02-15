require 'pry'

class Dog

	attr_accessor :name, :breed, :id

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs  (
				id INTEGER PRIMARY KEY
				name TEXT
				breed TEXT)
		SQL
		# DB[:conn].execute(sql)
	end
	
	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs
		SQL
		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.breed )

		sql = <<-SQL
			SELECT last_insert_rowid() FROM dogs
	    SQL
	    @id = DB[:conn].execute(sql).flatten[0]
		Dog.new(name: self.name, breed: self.breed, id: self.id)
	end
		
	def update
	  	sql = <<-SQL
		UPDATE dogs
		SET name = ?, breed = ?
		WHERE id = ?
	  	SQL

	  	DB[:conn].execute(sql, self.name, self.breed, self.id)
  	end

  	def self.create(hash)
  		# @name = name
  		# @breed = breed
  		new_dog = self.new(name: hash[:name], breed: hash[:breed])
  		new_dog.save
  		new_dog
  	end

  	def self.find_by_id(id)
  		sql = <<-SQL
  		SELECT *
  		FROM dogs
  		WHERE id = ?
  		SQL

		dog_row = DB[:conn].execute(sql, id).flatten
		self.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
  	end

  	def self.find_or_create_by(name:, breed:)

  		sql = <<-SQL
  		SELECT *
  		FROM dogs
  		WHERE name = ?
  		AND breed = ?
  		SQL
  		
  		dog = DB[:conn].execute(sql, name, breed).flatten
  		
  		if !dog.empty?
  			dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
  		else
  			dog = self.create(name: name, breed: breed)
  		end
  		dog
  	end

  	def self.new_from_db(row)
  		self.new(id: row[0], name: row[1], breed: row[2])
  	end

  	def self.find_by_name(name)

  		sql = <<-SQL
  		SELECT *
  		FROM dogs
  		WHERE name = ?
  		SQL

		dog_row = DB[:conn].execute(sql, name).flatten
		
		self.find_or_create_by(name: dog_row[1], breed: dog_row[2])

  	end

end