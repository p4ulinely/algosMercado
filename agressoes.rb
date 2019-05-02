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
		# linha[4]= linha[4].to_f
		baseCSV.push(linha)
	end

	return baseCSV
end
#metodo para ler o arquivo

#metodo para criar um csv
def criarCsv(dados, nome="DOLQ18_agressoes_25")

	csv = File.open("#{nome}.csv", "w")

	## para cabecalho
	csv.print "preco;comprador;vendedor\n"

	dados.each do |valor|

		csv.print "#{valor[0]};#{valor[1]};#{valor[2]}\n"
	end

	# csv.close
end
#metodo para criar um csv

#metodo para 
def clusteringAgressoes(base, cluster = nil, tipoClust = "agressoes")
	
	# tipoClust = "diretos"

	if cluster == nil
		cluster = Array.new()
	end

	# comeca o laco de baixo pra cima
	for idx in (base.length-1).downto(0)

		if tipoClust == "agressoes"

			# apenas para agressoes compradoras ou vendedoras e maiores que 20 contratos
			if base[idx][7] != "Leilão" && base[idx][7] != "Direto" && base[idx][5].to_i > 20
			
				# pega o index do preco atual no array cluster
				idxPrecoAtual = cluster.index{|a| a[0] == base[idx][4]}

				# verifica se ja ha o preco em questao
				if idxPrecoAtual != nil
					if base[idx][7] == "Comprador"
						cluster[idxPrecoAtual][1] += base[idx][5].to_i

					elsif base[idx][7] == "Vendedor"
						cluster[idxPrecoAtual][2] += base[idx][5].to_i
					end
					
				else
					if base[idx][7] == "Comprador"
						cluster.push([base[idx][4], base[idx][5].to_i, 0])

					elsif base[idx][7] == "Vendedor"
						cluster.push([base[idx][4], 0, base[idx][5].to_i])
					end

				end # preco em questao
			end # leilao, direto e >20
		
		elsif tipoClust == "diretos"
			if base[idx][7] == "Direto" && base[idx][5].to_i > 995
				
				# pega o index do preco atual no array cluster
				idxPrecoAtual = cluster.index{|a| a[0] == base[idx][4]}

				# verifica se ja ha o preco em questao
				if idxPrecoAtual != nil
					cluster[idxPrecoAtual][1] += base[idx][5].to_i
				else
					cluster.push([base[idx][4], base[idx][5].to_i])
				end # preco em questao
			end # if
		end # diretos
			
	end #for

	return cluster
end
#metodo para 

agressoesAcumuladas = nil

(0..21).each do |i|

	if i == 0
		agressoesAcumuladas = clusteringAgressoes(lerArquivo("bd1.csv"))
	else
		begin
			agressoesAcumuladas = clusteringAgressoes(lerArquivo("bd#{i+1}.csv"), agressoesAcumuladas)
		rescue
			puts "o arquivo bd#{i+1}.csv nao existe"
		end
	end
		
end

# ordenando por preco z - a
agressoesAcumuladas = agressoesAcumuladas.sort.reverse

criarCsv(agressoesAcumuladas)
