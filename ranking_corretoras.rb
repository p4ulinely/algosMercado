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
def criarCsv(dados, nome="3108_corretoras_13")

	csv = File.open("#{nome}.csv", "w")

	## para cabecalho
	csv.print "corretora;compras;vendas;saldo\n"

	dados.each do |valor|

		csv.print "#{valor[0]};#{valor[1]};#{valor[2]};#{valor[3]}\n"
	end

	# csv.close
end
#metodo para criar um csv

#metodo para 
def clusteringAgressoesCorretoras(base, cluster = nil)

	horaLimite = 14

	if cluster == nil
		cluster = Array.new()
	end

	# comeca o laco de baixo pra cima
	for idx in (base.length-1).downto(0)

	hora = base[idx][2].split(":")[0].to_i

	# apenas para agressoes compradoras ou vendedoras, ate' derterminada hora
	if base[idx][7] != "Leilão" && base[idx][7] != "Direto" && hora < horaLimite

		idxCorretoraComp = cluster.index{|a| a[0] == base[idx][3]} # corretora Compradora
		idxCorretoraVend = cluster.index{|a| a[0] == base[idx][6]} # corretora Vendedora

		if idxCorretoraComp != nil # se Compradora ja' existe 
			cluster[idxCorretoraComp][1] += base[idx][5].to_i
		else
			cluster.push([base[idx][3], base[idx][5].to_i, 0, 0])
		end

		if idxCorretoraVend != nil # se Vendedora ja' existe 
			cluster[idxCorretoraVend][2] += base[idx][5].to_i
		else
			cluster.push([base[idx][6], 0, base[idx][5].to_i, 0])
		end	
	end
			
	end #for

	# calcula o saldo
	cluster.each { |e|  e[3] = e[1] - e[2]}

	# organiza pelo saldo a-z
	cluster.sort_by! { |e| e[3]}
	
	# print
	# cluster.each { |e|  print "#{e}\n"}

	return cluster
end
#metodo para 

criarCsv(clusteringAgressoesCorretoras(lerArquivo("DOLZ18_Trade_05-11-2018.csv")))

