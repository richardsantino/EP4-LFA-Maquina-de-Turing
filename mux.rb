require 'json' # Pra abrir o json

class Cell # Cada caractere da máquina de turing é uma célula, tipo os quadradinhos mesmo
  attr_accessor :value       # Valor daquela célula
  attr_accessor :being_read  # valor booleano pra dizer se o leitor da máquina está nessa célula

  # Função pra inicializar a célula
  def initialize(settings_hash)
    @value = settings_hash[:value]
    @being_read = settings_hash[:being_read]
  end

end


class MuxTuringMachine # máquina de Turing em si
  attr_accessor :verbose # valor booleano pra dizer se vai imprimir o output completo
  
  # Inicializa a máquina
  def initialize(initial_tape_value, transition_filename, reading)
    @tape = set_tape(initial_tape_value)                      # Inicializa a fita com os valores
    @tape.default = Cell.new({value: "e", being_read: false}) # Coloca os espaços em branco com o caractere de espaço em branco
    @reading_head = reading                                         # Posiciona o leitor em zero
    @transition_table = load_transitions(transition_filename) # Carrega as transições de estado do arquivo json
    @current_state = 0                                        # Coloca o primeiro estado como zero
    @final_state = @transition_table.length - 1               # Coloca o estado final como o último estado presente no json
    @verbose = false
  end

  # Imprime a fita
  def print_tape
    sorted_keys = @tape.keys.map{|x| x.to_i}.sort.map{|x| x.to_s} # Mapeia a fita em ordem
    sorted_keys.each do |key| # Basicamente um If de impressão
      print "#{@tape[key].value}|" unless @tape[key].being_read  # if (a fita não está sendo lida): imprime isso
      print "#{@tape[key].value}*|" if @tape[key].being_read     #else: imprime isso
    end
    puts ""
  end

  # Roda o processo
  def run
    while @current_state != @final_state do # Enquanto não estivermos no estado final, executa esse bloco
      if @current_state == 20
        puts "Erro! Fita rejeitada!"
        return
      end

      unless @tape.has_key? @reading_head.to_s # Se o leitor estiver numa célula que não existe, cria a célula com o símbolo de vazio
        @tape[@reading_head.to_s] = Cell.new({value: "e", being_read: false})
      end
      @tape[@reading_head.to_s].being_read = true # Indica que aquela célula está sendo lida
      print_tape
      state = @transition_table[@current_state] # Pega as instruções daquele estado
      puts "Estado atual: #{@current_state}" if @verbose

      # A máquina funciona baseado nas posições que estão no json, seria equivalente a salvar as instruções num array e aí fazer um instruções[valor]
      read_value = @tape[@reading_head.to_s].value.to_s

      case read_value
        when "W"
          read_value = 2
        when "X"
          read_value = 3
        when "Y"
          read_value = 4
        when "S"
          read_value = 5
        when "#"
          read_value = 6
        when "e"
          read_value = 7
      end


      state = state[read_value.to_i] # Salva o estado em que a gente está
      puts "#Foi lido um #{read_value}" if @verbose

      @tape[@reading_head.to_s].value = state["write"] # Escreve na fita o que aquele estado mandar escrever
      puts "Foi escrito um #{state["write"]}" if @verbose
      @tape[@reading_head.to_s].being_read = false # A fita não está mais sendo lida

      # Movimenta a fita pro lado que o estado escrever
      if state["direction"] == "R"
        move_right
        puts "Movi para a direita" if @verbose
      else
        move_left
        puts "Movi para a esquerda" if @verbose
      end
      # Avança o estado
        @current_state = state["next_state"]
        puts "Atualizado para o estado #{@current_state}" if @verbose
        puts "-------------------------------------------" if @verbose
    end
    return @tape, @reading_head
  end

  private
  def set_tape(value) # Cria as células pra cada caractere
    tape = Hash.new
    value.split("").each_with_index do |value, i|
      tape[i.to_s] = Cell.new({value: value, being_read: false})
    end
    tape
  end

  def load_transitions(filename) # Carrega o arquivo json
    file = File.read(filename)
    JSON.parse(file)
  end

  def move_right # Move o leitor
    @reading_head += 1
  end

  def move_left # Move o leitor
    @reading_head -= 1
  end
end