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
def criarCsv(dados, nome="volumeMedio")

	csv = File.open("#{nome}.csv", "w")

	hora = 0

	(0..dados[0].length-1).each do |i|
		
		## para cabecalho
		csv.print "dia#{[i+1]}\n"
		
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
def clusteringVolumes(base)
	
	cluster = Array.new()
	horaInicial = 0
	volumeCompras = 0
	volumeVendas = 0
	volumeDiretos = 0
	valMax = 0.0
	valMin = 0.0

	for idx in (base.length-1).downto(0)

		if horaInicial == 0
			horaInicial = base[idx][2].split(":")[0].to_i

			# para max e min
			valMax = base[idx][4].to_f
			valMin = base[idx][4].to_f
			
			# para volume
			if base[idx][7] == "Comprador"
				volumeCompras = base[idx][5].to_i
			elsif base[idx][7] == "Vendedor"
				volumeVendas = base[idx][5].to_i
			elsif base[idx][7] == "Direto"
				volumeDiretos = base[idx][5].to_i		
			end

			next
		end

		horaAtual = base[idx][2].split(":")[0].to_i
		
		if horaAtual == horaInicial

			# para max e min
			if base[idx][4].to_f > valMax
				valMax = base[idx][4].to_f
			elsif base[idx][4].to_f < valMin
				valMin = base[idx][4].to_f
			end

			# para volume
			if base[idx][7] == "Comprador"
				volumeCompras += base[idx][5].to_i
			elsif base[idx][7] == "Vendedor"
				volumeVendas += base[idx][5].to_i
			elsif base[idx][7] == "Direto"
				volumeDiretos += base[idx][5].to_i		
			end
			
		#quando a hora muda, salva os volumes negociados ate o momento
		else
			cluster.push([horaInicial, volumeCompras, volumeVendas, volumeDiretos, volumeCompras-volumeVendas, volumeCompras+volumeVendas+volumeDiretos, (valMax-valMin).to_f])
			
			horaInicial = horaAtual

			# para max e min
			valMax = base[idx][4].to_f
			valMin = base[idx][4].to_f
			
			# para volume
			if base[idx][7] == "Comprador"
				volumeCompras = base[idx][5].to_i
			elsif base[idx][7] == "Vendedor"
				volumeVendas = base[idx][5].to_i
			elsif base[idx][7] == "Direto"
				volumeDiretos = base[idx][5].to_i		
			end
		end

		if idx == 0 #para a ultima hora
			cluster.push([horaInicial, volumeCompras, volumeVendas, volumeDiretos, volumeCompras-volumeVendas, volumeCompras+volumeVendas+volumeDiretos, (valMax-valMin).to_f])
		end

	end #for

	return cluster
end
#metodo para verificar maior e menor valor a cada hora


bases = Array.new()

#lendo csvs
bases[0] = clusteringVolumes(lerArquivo("DOLV18_Trade_03-09-2018.csv"))
# bases[1] = clusteringVolatilidade(lerArquivo("DOLK18_Trade_02-04-2018.csv"))

print bases

# criarCsv(bases)
