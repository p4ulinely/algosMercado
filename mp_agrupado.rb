#metodo para ler o arquivo
def lerArquivo(umEndereco)

	arquivoExterno = File.open(umEndereco, "r")

	baseCSV = Array.new()

	while linha = arquivoExterno.gets
		linha = linha.chop
		#linha = linha.force_encoding('utf-8')
		# linha = linha.force_encoding('iso-8859-1').encode('utf-8')
		linha = linha.split(";")
		linha[2] = linha[2].to_f
		linha[3] = linha[3].to_f

		baseCSV.push(linha)
	end

	return baseCSV
end
#metodo para ler o arquivo

#metodo para criar um csv
def criarCsv(resultado, nome="mpAgrupado")

	csv = File.open("#{nome}.csv", "w")

	resultado.each_index do |i|

		# insere ; entre as letras
		# temp = resultado[i][1].split('')
		# temp = temp.join(';')

		temp = resultado[i][1]

		csv.print "#{resultado[i][0]};#{temp}\n"
	end
end


def criarMp(arquivo)

	mp = Array.new()
	arrTemp = Array.new()
	# mp = [[3940, "x"], [3935.5, "xxx"], [3945.5, "xx"]]

	for idx in (arquivo.length-1).downto(0)
		
		# criar precos de acordo com max e min
		i = arquivo[idx][2]
		while i >= arquivo[idx][3]
			arrTemp.push(i)
			i = i - 0.5
		end

		# verifica se os precos criados ja existem
		arrTemp.each do |conteudo|

			jaExiste = nil

			# Procura se o preco ja existe
			mp.each_index do |i| 
				if mp[i][0] == conteudo
					jaExiste = i
				end
			end

			# caso ja exista, adiciona mais um x
			if jaExiste != nil
				mp[jaExiste][1] = mp[jaExiste][1] + "x"
			
			# do contrario, cria um novo preco
			else
				mp.push([conteudo, "x"])
			end
		end
	end

	# ordena pelo preco
	mp.sort_by! {|p| p[0]} # max -> min
	mp.reverse! {|p| p[0]} # min -> max

	return mp
end

resultado = criarMp(lerArquivo("DOLFUT_30min_max-min.csv"))
criarCsv(resultado)
