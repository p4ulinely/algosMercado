class Dia
	def initialize(dia, max1h, min1h, vol1h)
		@dia = dia #data do candle
		@max1h = max1h #maxima de primeria hora
		@min1h = min1h #minima da primeira hora
		@vol1h = vol1h #volume da primeira hora
		@vlt1h = max1h - min1h #volatilidade da primeira hora
		@vol = vol1h #volume do dia
		@max = max1h #maxima do dia
		@min = min1h #minnima do dia
		@vlt = @vlt1h #volatilidade do dia
		@qntCandles = 1

		######## para analise da primeira hora
		@passouDaMax1h = false
		@passouDaMin1h = false
		######## para analise da primeira hora
	end

	def getDia
		@dia	
	end

	def getVolume
		@vol	
	end

	def getQntCandles
		@qntCandles
	end

	def passouPrimeiraHora
		[@passouDaMax1h, @passouDaMin1h]
	end

	def addCandle(max, min, vol)

		@qntCandles += 1
		
		if max > @max
			@max = max # nova maxima
		end

		if min < @min
			@min = min # nova minima
		end

		######## para analise da primeira hora
		if @max > @max1h
			@passouDaMax1h = true
		end

		if @min < @min1h
			@passouDaMin1h = true
		end
		######## para analise da primeira hora

		# novo volume
		@vol += vol

		# nova volatilidade
		@vlt = @max - @min
	end
end #classe Dia

#metodo para ler o arquivo
def lerArquivo(umEndereco, tipo=1)

	arquivoExterno = File.open(umEndereco, "r")

	baseCSV = Array.new()

	while linha = arquivoExterno.gets
		linha = linha.chop
		#linha = linha.force_encoding('utf-8')
		# linha = linha.force_encoding('iso-8859-1').encode('utf-8')

		# csv do profit
		if tipo == 1
			linha = linha.split(";")
		
			# precos para float
			(3..6).each do |num|
				linha[num] = linha[num].to_f
			end

			# volume para inteiro
			linha[8] = linha[8].to_i	
		
		#csv api
		else
			linha = linha.split(",")
		
			# precos para float
			(1..4).each do |num|
				linha[num] = linha[num].to_f
			end

			# volume para inteiro
			linha[5] = linha[5].to_i		
		end


		baseCSV.push(linha)
	end

	return baseCSV
end

#metodo para ler o arquivo

#metodo para criar um csv
# def criarCsv(resultado, nome="meuCsv")

# 	csv = File.open("#{nome}.csv", "w")

# 	resultado.each_index do |i|

# 		# insere ; entre as letras
# 		# temp = resultado[i][1].split('')
# 		# temp = temp.join(';')

# 		temp = resultado[i][1]

# 		csv.print "#{resultado[i][0]};#{temp}\n"
# 	end
# end

@diaTemp = nil
@controle = 0

def candle(repositorio, candle, i_candle, tipo)

	# csv do profit
	if tipo == 1

		# if @diaTemp == nil
		# 	horaInicial = "09:00:00"
		# else
			
		# end
		horaInicial = "09:00:00"
		horaCandle = candle[i_candle][2]

	# csv api
	else
		horaInicial = "11:00:00"
		horaCandle = candle[i_candle][7].split(' ')[1].gsub('"', '')
	end

	# primeira hora
	if horaCandle == horaInicial

		# if i_candle != candle.length-1
		# 	puts i_candle
		# 	puts @diaTemp.getQntCandles
		# end

		if @diaTemp != nil # para evitar um push no primeiro candle do csv
			puts @diaTemp.getQntCandles
			repositorio.push(@diaTemp)
			@controle += 1
		end

		if tipo == 1
			@diaTemp = Dia.new(candle[i_candle][1], candle[i_candle][4], candle[i_candle][5], candle[i_candle][8])
		else
			@diaTemp = Dia.new(candle[i_candle][7].split(' ')[0].gsub('"', ''), candle[i_candle][2], candle[i_candle][3], candle[i_candle][5])
		end
	# demais horas
	else

		if tipo == 1
			@diaTemp.addCandle(candle[i_candle][4], candle[i_candle][5], candle[i_candle][8])
		else
			@diaTemp.addCandle(candle[i_candle][2], candle[i_candle][3], candle[i_candle][5])
		end
		
		# quando chega no ultimo candle do csv, adiciona os dados do dia corrente
		if tipo == 1
			if i_candle == 0
				repositorio.push(@diaTemp)
			end
		else
			if i_candle == candle.length-1
				repositorio.push(@diaTemp)
			end
		end
	end
end # def candle(

def repositorioDias(arquivo, tipo=1)

	arrTemp = Array.new()

	#csv do profit
	if tipo == 1

		for linha_arquivo in (arquivo.length-1).downto(0)
			candle(arrTemp, arquivo, linha_arquivo, tipo)	
		end #for
	
	#csv api
	else
		for linha_arquivo in (0..arquivo.length-1)
			# print "#{linha_arquivo} "
			candle(arrTemp, arquivo, linha_arquivo, tipo)
		end #for
	end

	return arrTemp
end # def repositorioDias(

file = lerArquivo("dolfut.txt")
repo = repositorioDias(file)
# file = lerArquivo("organizado.csv", 2)
# repo = repositorioDias(file, 2)
# puts repo[30].getQntCandles
# puts @controle

############# analise
max1h, min1h, ambos, nenhum = 0, 0, 0, 0
t = repo.length

repo.each do |dia|

	# max1h
	if dia.passouPrimeiraHora[0] && dia.passouPrimeiraHora[1] == false
		max1h += 1
	end

	if dia.passouPrimeiraHora[1] && dia.passouPrimeiraHora[0] == false
		min1h += 1
	end

	if dia.passouPrimeiraHora[0] && dia.passouPrimeiraHora[1]
		ambos += 1
	end

	if !dia.passouPrimeiraHora[0] && !dia.passouPrimeiraHora[1]
		nenhum += 1
	end
end

puts "\nresultado: para #{t} dias"

print "max1h: #{(max1h/t.to_f)*100} (#{max1h})\n"
print "min1h: #{(min1h/t.to_f)*100} (#{min1h})\n"
print "ambos: #{(ambos/t.to_f)*100} (#{ambos})\n"
print "nenhum: #{(nenhum/t.to_f)*100} (#{nenhum})\n"
print "\tapenas um lado: #{((max1h+min1h)/t.to_f)*100} (#{(max1h+min1h)})\n"
############# analise

