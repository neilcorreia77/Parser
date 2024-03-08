#
#  Parser Class
#
load "TinyToken.rb"
load "TinyLexer.rb"
class Parser < Lexer
	attr_accessor :totalerrors
	def initialize(filename)

    	super(filename)
		@totalerrors = 0
    	consume()
   	end
   	
	def consume()
      	@lookahead = nextToken()
      	while(@lookahead.type == Token::WS)
        	@lookahead = nextToken()
      	end
   	end
  	
	def match(*dtype)
		if (!dtype.include? @lookahead.type)
		  if (dtype.length() > 1)
			dtype.map!(&:upcase)
		  end
		  puts "Expected #{dtype.join(" or ")} found #{@lookahead.text}"
		  @totalerrors += 1
		end
		consume()
	end
   	
	def program()
      	while( @lookahead.type != Token::EOF)
        	puts "Entering STMT Rule"
			statement()  
      	end
		  puts "There were #{@totalerrors} parse errors found."
   	end

	def statement()
		if (@lookahead.type == Token::PRINT)
			puts "Found PRINT Token: #{@lookahead.text}"
			match(Token::PRINT)
			exp()
		else
			assign()
		end
		
		puts "Exiting STMT Rule"
	end

    def assign()
		puts "Entering ASSGN Rule"

		if (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
		end
		match(Token::ID)
		if (@lookahead.type == Token::ASSGN)
			puts "Found ASSGN Token: #{@lookahead.text}"
		end
		match(Token::ASSGN)
		exp()

		puts "Exiting ASSGN Rule"
	end

    
    def exp()
		puts "Entering EXP Rule"
		term()
		etail()
		puts "Exiting EXP Rule"
	end

	def term()
		puts "Entering TERM Rule"
		factor()
		ttail()
		puts "Exiting TERM Rule"
	end

    def factor()
		puts "Entering FACTOR Rule"

		if (@lookahead.type == Token::LPAREN)
			puts "Found LPAREN Token: #{@lookahead.text}"
			match(Token::LPAREN)
			exp()
			if (@lookahead.type == Token::RPAREN)
				puts "Found RPAREN Token: #{@lookahead.text}"
			end
			match(Token::RPAREN)
		elsif (@lookahead.type == Token::INT)
			puts "Found INT Token: #{@lookahead.text}"
			match(Token::INT)
		elsif (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			match(Token::ID)
		else
			match(Token::LPAREN, Token::INT, Token::ID)
		end

		puts "Exiting FACTOR Rule"
	end

	def ttail() 
		puts "Entering TTAIL Rule"

		if (@lookahead.type == Token::MULTOP)
			puts "Found MULTOP Token: #{@lookahead.text}"
			match(Token::MULTOP)
			factor()
			ttail()
		elsif (@lookahead.type == Token::DIVOP)
			puts "Found DIVOP Token: #{@lookahead.text}"
			match(Token::DIVOP)
			factor()
			ttail()
		else
			epsilons("MULTOP", "DIVOP")
		end

		puts "Exiting TTAIL Rule"
	end

	def etail()
		puts "Entering ETAIL Rule"
		if (@lookahead.type == Token::ADDOP)
			puts "Found ADDOP Token: #{@lookahead.text}"
			match(Token::ADDOP)
			term()
			etail()
		elsif (@lookahead.type == Token::SUBOP)
			puts "Found SUBOP Token: #{@lookahead.text}"
			match(Token::SUBOP)
			term()
			etail()
		else
			epsilons("ADDOP", "SUBOP")
		end
		puts "Exiting ETAIL Rule"
	end

	def epsilons(*tokens)
		puts "Did not find #{tokens.join(" or ")} Token, choosing EPSILON production"
	end

end
