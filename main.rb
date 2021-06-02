require './mux.rb'
require './pot.rb'

# Função pro usuário digitar o calculo dele e ela validar se realmente só tem zero e um nela
def getExpression
  while true
    puts "Digite a sua operação utilizando 0 e 1 de forma alternada (ou seja, 2*2 ou 2^2 ficariam como 0011):\n"
    expression = gets.chomp
    if expression.count('01') != expression.size
      system "clear"
      puts "Você cometeu algum erro ao digitar o cálculo. Por favor, digite novamente"
    else
      return expression
    end
  end
end

# É um if pra definir o tipo de impressão, fiz numa função pra organizar
def definePrinting
  while true
    puts "\nVocê gostaria de imprimir a saída completa do programa?\n(\"Y\" para sim / \"N\" para não:)"
    choice = gets.chomp
    if choice == "Y" || choice == "y"
      return true
    elsif choice == "N" || choice == "n"
      return false
    else
      system "clear"
      puts "Erro! Por favor, digite novamente."
    end
  end
end

# Imprimir a fita que retornou da maquina
def printResult(expression, result)
  puts "\nExpressão digitada:"
  puts expression
  finalResult = ""
  sorted_keys = result.keys.map{|x| x.to_i}.sort.map{|x| x.to_s}
  sorted_keys.each do |key|
    finalResult = finalResult + result[key].value.to_s if result[key].value != "e"
  end
  puts "\nResultado final: "
  puts finalResult
  puts finalResult.length
  puts "\n------------------------------------------------\n"

  puts "Gostaria de digitar outro cálculo? (\"Y\" para sim / \"N\" para não:):"
  choice = gets.chomp
  if choice == "Y" || choice == "y"
      return true
  elsif choice == "N" || choice == "n"
      return false
  else
      puts "Erro! Recomeçando o programa!"
      return true
  end
end


# Inicialização: decidir qual calculo quer fazer
puts "Máquinas de Turing\n"
while true
  puts "Selecione o tipo de cálculo que você gostaria de fazer:\n1- Multiplicação\n2- Potência\n3- Sair do programa"
choice = gets.chomp
system "clear"
  case choice.to_i
    when 1
      puts "Você escolheu multiplicação."
      expr = getExpression
      mux = MuxTuringMachine.new(expr, "mux.json", 0)
      mux.verbose = definePrinting 
      result, reading = mux.run
      again = printResult(expr, result)
      if not again
        break
      end
    when 2
      puts "Você escolheu potenciação."
      expr = getExpression
      pot = PotTuringMachine.new(expr, "pot.json")
      pot.verbose = definePrinting 
      result = pot.run
      again = printResult(expr, result)
      if not again
        break
      end
    when 3
      break
    else
      system "clear"
      puts "Erro, digite novamente"
  end
end
puts "Obrigado por usar o programa :)"