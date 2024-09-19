
-- Eli Makoto Higashi Matias
-- RGM: 11221101848


-- Criação do Banco Clínica Veterinária 

CREATE DATABASE Clinicaveterinaria;

USE Clinicaveterinaria;



-- Criação da tabela pacientes
CREATE TABLE pacientes ( id_paciente INT PRIMARY KEY AUTO_INCREMENT, 
nome VARCHAR (100), especie VARCHAR(50), idade INT );



-- Inserindo valores nos campos da tabela pacientes
INSERT INTO pacientes (nome, especie, idade) VALUES ('Pipoca','Gato','7'),('Bela','Papagaio','10'),('Bolt','Cachorro','14');

SELECT * FROM pacientes;


-- Criação da tabela veterinarios
CREATE TABLE veterinarios (id_veterinario INT 
PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(100),
especialidade VARCHAR(50));


-- Inserindo valores nos campos da tabela pacientes
INSERT INTO veterinarios (nome, especialidade )VALUES ('Leticia Ribeiro','Veterinária'),('Nicole Monteiro','Veterinária'),('Camila Neves','Veterinária');

SELECT * FROM veterinarios;


-- Criação da tabela consultas
CREATE TABLE consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT,
    id_veterinario INT,
    data_consulta DATE NOT NULL,
    custo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario)
);



-- Criação de Procedure agendar a consulta 
DELIMITER //
CREATE PROCEDURE agendar_consulta(IN pr_id_paciente INT, IN pr_id_veterinario INT, 
pr_data_consulta DATE, pr_custo DECIMAL (10,2))
BEGIN
INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (pr_id_paciente, pr_id_veterinario, pr_data_consulta, pr_custo);
END //
DELIMITER ;

CALL agendar_consulta(1, 1, '2024-07-10', 150.00);
CALL agendar_consulta(2, 2, '2024-07-20', 120.00);
CALL agendar_consulta(3, 3, '2024-07-21', 140.00);

SELECT * FROM consultas;




-- Criação de Procedure para atualizar o paciente
DELIMITER //
CREATE PROCEDURE atualizar_paciente(IN pr_id_paciente INT, IN pr_novo_nome VARCHAR (100), 
pr_nova_especie VARCHAR (50), pr_nova_idade INT)
BEGIN
 UPDATE pacientes
    SET nome = pr_novo_nome,
        especie = pr_nova_especie,
        idade = pr_nova_idade
    WHERE id_paciente = pr_id_paciente;

END //
DELIMITER ;

-- Atualizar os pacientes

CALL atualizar_paciente('1','Cacau','Coelho','1');
CALL atualizar_paciente('2','Spike','Iguana','10');
CALL atualizar_paciente('3','Thor','Peixe','3');

SELECT * FROM pacientes;





-- Criação de Procedure para remover a consulta do paciente
DELIMITER //
CREATE PROCEDURE remover_consulta(IN pr_id_consulta INT)
BEGIN
DELETE FROM consultas
    WHERE id_consulta = pr_id_consulta;
END //
DELIMITER ;

-- Remover as consultas

CALL remover_consulta(1);
CALL remover_consulta(2);
CALL remover_consulta(3);



SELECT * FROM consultas;

-- Agendar Clientes

CALL agendar_consulta(1, 1, '2024-07-10', 150.00);
CALL agendar_consulta(2, 2, '2024-07-20', 120.00);
CALL agendar_consulta(3, 3, '2024-07-21', 140.00);


SELECT * FROM consultas;




-- Function para saber o valor total gasto pelo paciente
DELIMITER //
CREATE FUNCTION total_gasto_paciente(pr_id_paciente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    
    SELECT SUM(custo) INTO total
    FROM consultas
    WHERE id_paciente = pr_id_paciente;

    
    IF total IS NULL THEN
        SET total = 0.00;
    END IF;

    RETURN total;
END //

DELIMITER ;


SELECT 
    p.id_paciente,
    p.nome,
    IFNULL(SUM(c.custo), 0.00) AS total_gasto
FROM 
    pacientes p
LEFT JOIN 
    consultas c ON p.id_paciente = c.id_paciente
GROUP BY 
    p.id_paciente, p.nome;



-- Trigger para verificar a idade do paciente

DELIMITER //

CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    -- Verifica se a idade é menor ou igual a 0
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A idade do paciente deve ser um número positivo.';
    END IF;
END //

DELIMITER ;

INSERT INTO pacientes (nome, especie, idade) VALUES ('Mini', 'Papagaio', -7);


-- Criação da tabela de log
CREATE TABLE log_de_consultas (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    custo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2),
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
);


-- Criação da Trigger para registrar alterações de custo
DELIMITER //
CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO log_de_consultas (id_consulta, custo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //
DELIMITER ;

SELECT * FROM consultas;

-- Atualizar o custo das consultas

UPDATE consultas SET custo = 210.00 WHERE id_consulta = 4;
UPDATE consultas SET custo = 70.00 WHERE id_consulta = 5;
UPDATE consultas SET custo = 21.00 WHERE id_consulta = 6;


-- Verificar a tabela de Log
SELECT * FROM log_de_consultas;






