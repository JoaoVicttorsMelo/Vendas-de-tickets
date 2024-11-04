require 'securerandom'
require 'json'
require 'cpf_cnpj'

class VendaTickets
  def initialize(nome,cpf, poltrona)
    @nome = nome
    @cpf = cpf
    @poltrona = poltrona.to_s.upcase
    reservar_lugar
  end

  def pegar_json
    caminho_arquivo = File.join(__dir__, 'arquivos.txt')
    if File.exist?(caminho_arquivo) && !File.empty?(caminho_arquivo)
      conteudo = File.read(caminho_arquivo)
      JSON.parse(conteudo)
    else
      { "reservas" => [] }
    end
  end

  def lugare_reservados
    dados = pegar_json
    dados["reservas"]
  end

  def verificar_poltrona(poltrona)
    json = pegar_json
    if json['reservas'].any? {|reserva| reserva["poltrona"] == poltrona}
      true
    else
      false
    end
  end

  def validar_cpf(cpf)
    cpf_limpo = cpf.gsub(/\D/, '')

    unless cpf_limpo.length == 11
      p "CPF deve conter exatamente 11 dígitos."
    end

    if cpf_limpo.chars.uniq.length == 1
      p "CPF não pode conter todos os dígitos iguais."
    end

    unless CPF.valid?(cpf_limpo)
      p "CPF inválido (falha na verificação dos dígitos)."
    end

    true
  end

  def verificar_cpf_json(cpf)
    json = pegar_json
    if json['reservas'].any? {|reserva| reserva["cpf"] == cpf}
      false
    else
      true
    end
  end


  def reservar_lugar
    poltronas_estadio = %w[A1 A2 A3 A4 A5 B1 B2 B3 B4 B5 C1 C2 C3 C4 C5 D1 D2 D3 D4 D5 E1 E2 E3 E4 E5 F1 F2 F3 F4 F5 G1 G2 G3 G4 G5 H1 H2 H3 H4 H5 I1 I2 I3 I4 I5 J1 J2 J3 J4 J5 J6]
    lugar_utilizado = lugare_reservados.map {|lugares| lugares['poltrona']}
    if poltronas_estadio.size >= lugar_utilizado.size
      if poltronas_estadio.include?(@poltrona) && !verificar_poltrona(@poltrona)
        valor_ticket = gerar_ticket
        if validar_cpf(@cpf)
          if verificar_cpf_json(@cpf)
            inserir_json(@nome,@cpf , @poltrona, valor_ticket)
            puts "Ticket gerado com sucesso, seu ticket = #{valor_ticket}"
          end
        else
          puts "Não existe a poltrona informada ou já foi reservada"
        end
      end
    end
  end

  def inserir_json(nome, cpf, poltrona, ticket_gerado)
    json = pegar_json
    json["reservas"] << {
      "nome" => nome,
      "cpf" => cpf,
      "poltrona" => poltrona,
      "ticket" => ticket_gerado
    }
    salvar_json(json)
  end

  def salvar_json(json)
    file_path = File.join(__dir__, 'arquivos.txt')
    File.open(file_path,'w') do |f|
      f.write(JSON.pretty_generate(json))
    end
  end


  def gerar_ticket
    ticket_utilizado = lugare_reservados.map {|tickets| tickets['ticket']}
    letras_aleatorias(ticket_utilizado)
  end

  def letras_aleatorias(ticket_existentes)
    loop do
    codigo = SecureRandom.alphanumeric(6)
    unless ticket_existentes.include? codigo
      return codigo.upcase
    end
    end
  end
end

puts "Digita seu nome:"
nome = gets.chomp
puts "Digita seu cpf:"
cpf = gets.chomp
puts "Digita sua poltrona"
poltrona = gets.chomp

VendaTickets.new(nome,cpf, poltrona)