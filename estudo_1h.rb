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
		@qntCandles = 1 #quantidade de candles do dia

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
	def getVolatilidade
		@vlt
	end
	def getVolume1h
		@vol1h	
	end
	def getVolatilidade1h
		@vlt1h
	end
	def getQntCandles
		@qntCandles
	end
	def passouPrimeiraHora
		[@passouDaMax1h, @passouDaMin1h]
	end
	def vltPassou1h
		[@vltPassouMax1h, @vltPassouMin1h]
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

		# quantidade de pontos que passou de 1h
		@vltPassouMax1h = @max - @max1h
		@vltPassouMin1h = @min - @min1h
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

	# tipo 1 e' csv do profit
	# tipo 2 e' csv da api

	# para primeira linha
	if @diaTemp == nil

		if tipo == 1
			@diaTemp = Dia.new(candle[i_candle][1], candle[i_candle][4], candle[i_candle][5], candle[i_candle][8])
		else
			@diaTemp = Dia.new(candle[i_candle][7].split(' ')[0].gsub('"', ''), candle[i_candle][2], candle[i_candle][3], candle[i_candle][5])
		end

	# 
	else

		# determinar o dia corrente
		if tipo == 1
			diaCandle = candle[i_candle][1]
		else
			diaCandle = candle[i_candle][7].split(' ')[0].gsub('"', '')
		end

		# compara o dia corrente com o dia na classe
		if diaCandle != @diaTemp.getDia
			# puts diaCandle
			# exit
			repositorio.push(@diaTemp)
			
			if tipo == 1
				@diaTemp = Dia.new(candle[i_candle][1], candle[i_candle][4], candle[i_candle][5], candle[i_candle][8])
			else
				@diaTemp = Dia.new(candle[i_candle][7].split(' ')[0].gsub('"', ''), candle[i_candle][2], candle[i_candle][3], candle[i_candle][5])
			end
		else

			if tipo == 1
				@diaTemp.addCandle(candle[i_candle][4], candle[i_candle][5], candle[i_candle][8])
			else
				@diaTemp.addCandle(candle[i_candle][2], candle[i_candle][3], candle[i_candle][5])
			end
			
		end

		# para a ultima linha
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
			candle(arrTemp, arquivo, linha_arquivo, tipo)
		end #for
	end

	return arrTemp
end # def repositorioDias(

# file = lerArquivo("dolfut.txt")
# repo = repositorioDias(file)

# file = lerArquivo("organizado18.csv", 2)
# repo = repositorioDias(file, 2)

file = lerArquivo("organizado19.csv", 2)
repo = repositorioDias(file, 2)

############################################################### analise
t, max1h, min1h, ambos, nenhum = 0, 0, 0, 0, 0
mediaVolMin, mediaVolMax, mediaVolAmbos = 0.0, 0.0, 0.0
mediaVltMin, mediaVltMax, mediaVltAmbos = 0.0, 0.0, 0.0
mediaVolMin1h, mediaVolMax1h, mediaVolAmbos1h = 0.0, 0.0, 0.0
mediaVltMin1h, mediaVltMax1h, mediaVltAmbos1h = 0.0, 0.0, 0.0


repo.each do |dia|

	#dias com, pelo menos 9hrs de negociacao
	if dia.getQntCandles > 8
	# if dia.getQntCandles < 9

		t += 1	

		# max1h
		if dia.passouPrimeiraHora[0] && dia.passouPrimeiraHora[1] == false
			mediaVolMax += dia.getVolume
			mediaVolMax1h += dia.getVolume1h
			mediaVltMax += dia.getVolatilidade
			mediaVltMax1h += dia.getVolatilidade1h
			max1h += 1
		end

		if dia.passouPrimeiraHora[1] && dia.passouPrimeiraHora[0] == false
			mediaVolMin += dia.getVolume
			mediaVolMin1h += dia.getVolume1h
			mediaVltMin += dia.getVolatilidade
			mediaVltMin1h += dia.getVolatilidade1h
			min1h += 1
		end

		if dia.passouPrimeiraHora[0] && dia.passouPrimeiraHora[1]
			# print "#{dia.vltPassou1h[0]} #{dia.vltPassou1h[1]}, "
			print "#{dia.vltPassou1h[0] + dia.vltPassou1h[1]}, "
			mediaVolAmbos += dia.getVolume
			mediaVolAmbos1h += dia.getVolume1h
			mediaVltAmbos += dia.getVolatilidade
			mediaVltAmbos1h += dia.getVolatilidade1h
			ambos += 1
		end

		if !dia.passouPrimeiraHora[0] && !dia.passouPrimeiraHora[1]
			nenhum += 1
		end
	end
end # each

puts "\nresultado: para #{t} dias"

print "max1h: #{((max1h/t.to_f)*100).round(2)} (#{max1h}) | med vol: #{(mediaVolMax/max1h).to_i} | med vlt: #{(mediaVltMax/max1h).round(2)} | med vol1h: #{(mediaVolMax1h/max1h).to_i} | med vlt1h: #{(mediaVltMax1h/max1h).round(2)}\n"
print "min1h: #{((min1h/t.to_f)*100).round(2)} (#{min1h}) | med vol: #{(mediaVolMin/min1h).to_i} | med vlt: #{(mediaVltMin/min1h).round(2)} | med vol1h: #{(mediaVolMin1h/min1h).to_i} | med vlt1h: #{(mediaVltMin1h/min1h).round(2)}\n"
print "ambos: #{((ambos/t.to_f)*100).round(2)} (#{ambos}) | med vol: #{(mediaVolAmbos/ambos).to_i} | med vlt: #{(mediaVltAmbos/ambos).round(2)} | med vol1h: #{(mediaVolAmbos1h/ambos).to_i} | med vlt1h: #{(mediaVltAmbos1h/ambos).round(2)}\n"
print "nenhum: #{((nenhum/t.to_f)*100).round(2)} (#{nenhum})\n"
print "\tapenas um lado: #{((max1h+min1h)/t.to_f)*100} (#{(max1h+min1h)})\n"
puts "---------------------------------------------------"
############# analise

