#metodo para ler o arquivo
def lerArquivo(umEndereco)

	arquivoExterno = File.open(umEndereco, "r")

	baseCSV = Array.new()

	while linha = arquivoExterno.gets
		linha = linha.chop
		#linha = linha.force_encoding('utf-8')
		linha = linha.force_encoding('iso-8859-1').encode('utf-8')
		linha = linha.split(";")
		linha[4][4] = "." #substitui a ',' por um '.'

		baseCSV.push(linha)
	end

	return baseCSV
end
#metodo para ler o arquivo

#metodo para criar um csv
def criarCsv(dados, nome="volatilidadeMedia")

	csv = File.open("#{nome}.csv", "w")

	## para cabecalho
	csv.print "hora;"

	(0..dados.length-1).each do |dia|
		
		if dia == dados.length-1
			csv.print "dia#{dia+1}\n"
		else
			csv.print "dia#{dia+1};"
		end
	end
	## para cabecalho

	hora = 0

	(0..dados[0].length-1).each do |i|
		
		controle = true

		(0..dados.length-1).each do |j|
			if controle
				csv.print "#{dados[j][hora][0]};#{dados[j][hora][3]};"
				controle = false
			else
				if j == dados.length-1

					#begin e rescue e' um tratamento de exception.
					#printa zero, quando nao ha negociacao em uma determinada hora
					begin
						csv.print "#{dados[j][hora][3]}\n"
					rescue
						csv.print "0\n"
					end
				else
					begin
						csv.print "#{dados[j][hora][3]};"
					rescue
						csv.print "0;"
					end
				end
			end	
		end
		hora += 1
	end

end
#metodo para criar um csv

#metodo para verificar maior e menor valor a cada hora
def clusteringVolatilidade(base)
	cluster = Array.new()
	horaInicial = 0
	valMax = 0.0
	valMin = 0.0

	for idx in (base.length-1).downto(0)

		if horaInicial == 0
			horaInicial = base[idx][2].split(":")[0].to_i
			valMax = base[idx][4].to_f
			valMin = base[idx][4].to_f
			next
		end

		horaAtual = base[idx][2].split(":")[0].to_i
		
		if horaAtual == horaInicial
			if base[idx][4].to_f > valMax
				valMax = base[idx][4].to_f
			elsif base[idx][4].to_f < valMin
				valMin = base[idx][4].to_f
			end
		
		#quando a hora muda, salva o maior e o menor valor negociado ate o momento
		else
			cluster.push([horaInicial, valMin, valMax, (valMax-valMin).to_f])
			horaInicial = horaAtual
			valMax = base[idx][4].to_f
			valMin = base[idx][4].to_f
		end

		if idx == 0 #para a ultima hora
			cluster.push([horaInicial, valMin, valMax, (valMax-valMin).to_f])
		end

	end #for

	return cluster
end
#metodo para verificar maior e menor valor a cada hora

#metodo para calcular a volatilidades por hora de cinco dias
def mediasVolatilidade(arrVolatilidades)
	
	mediaVolatilidade = Array.new(arrVolatilidades[0].length, 0)

	(0..arrVolatilidades.length-1).each do |i|
		controle = 0

		arrVolatilidades[i].each do |h|
			
			mediaVolatilidade[controle] += h[3] #volatilidade
			controle += 1
		end
	end

	(0..mediaVolatilidade.length-1).each do |i|
		mediaVolatilidade[i] /= arrVolatilidades.length
	end

	return mediaVolatilidade
end
#metodo para calcular a volatilidades por hora de cinco dias

bases = Array.new()

#lendo csvs
bases[0] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_31-10-2018.csv"))
bases[1] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_01-11-2018.csv"))
bases[2] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_05-11-2018.csv"))
bases[3] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_06-11-2018.csv"))
bases[4] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_07-11-2018.csv"))
bases[5] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_08-11-2018.csv"))
bases[6] = clusteringVolatilidade(lerArquivo("DOLZ18_Trade_09-11-2018.csv"))



# puts "volatilidade media:"
# print mediasVolatilidade(bases)
# puts

criarCsv(bases)
