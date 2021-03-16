clear all %#ok<CLALL>
clc

%% Establecer conexion con el servidor
uaClient = opcua('Labo6',16700);   % Crear Instancia de OPC UA
connect(uaClient);                  % Conectarse al servidor
topNodes = uaClient.Namespace;      % Obtener espacio de nombres

% Creacion de nodos para recibir datos
readableNodes = CreateReadableNodes(topNodes);

% Creacion de nodos para escribir datos
writableNodes = CreateWritableNodes(topNodes);

%% Controlador
ControlFlag = true;
running = true;
while running
    try
        readNodes = readableNodes.readValue();
        % Conditional (ControlFlag) para calcular acciones de control y escribirlas.
        if ControlFlag
            % Calcular acciones de control
            control_actions = RunMA(readNodes);
            % Enviar acciones de control al SCADA
            control_actions = num2cell(control_actions); % Convertir array a cell
            writeValue(writableNodes, control_actions);
        end
        
        pause(30);   % Pausar por 30 segundos

    catch ME
        warning('Execution finished. Disconnecting OPC-UA server...')
        disconnect(uaClient);   % Desconectar el servidor
        rethrow(ME);
    end
end

%% Creación de nodos de lectura
function readableNodes = CreateReadableNodes(topNodes)
    % Creacion de nodos para recibir datos
    % Medidas del proceso
    Ca = findNodeByName(topNodes, 'Ca', '-once');
    Cb = findNodeByName(topNodes, 'Cb', '-once');
    q  = findNodeByName(topNodes, 'q' , '-once');
    Fr = findNodeByName(topNodes, 'qc', '-once');
    T  = findNodeByName(topNodes, 'T' , '-once');
    Tc = findNodeByName(topNodes, 'Tc', '-once');
    T0 = findNodeByName(topNodes, 'T0', '-once');
    Tc0 = findNodeByName(topNodes, 'Tc0', '-once');
    % Parametros del controlador
    Cb_sp = findNodeByName(topNodes, 'Cb_sp', '-once');
    T_sp  = findNodeByName(topNodes, 'T_sp' , '-once');

    % Restricciones
    LiminfT  = findNodeByName(topNodes, 'LiminfT' , '-once');
    LiminfCb = findNodeByName(topNodes, 'LiminfCb', '-once');
    Liminfq  = findNodeByName(topNodes, 'Liminfq' , '-once');
    LiminfFr = findNodeByName(topNodes, 'Liminfqc', '-once');
    LimsupT  = findNodeByName(topNodes, 'LimsupT' , '-once');
    LimsupCb = findNodeByName(topNodes, 'LimsupCb', '-once');
    Limsupq  = findNodeByName(topNodes, 'Limsupq' , '-once');
    LimsupFr = findNodeByName(topNodes, 'Limsupqc', '-once');

    % Precios
    p_Ca = findNodeByName(topNodes, 'p_Ca', '-once');
    p_Cb = findNodeByName(topNodes, 'p_Cb', '-once');
    p_Cc = findNodeByName(topNodes, 'p_Cc', '-once');
    p_Cd = findNodeByName(topNodes, 'p_Cd', '-once');
    p_Fr = findNodeByName(topNodes, 'p_Fr', '-once');

    % Verificar si esto funciona
    readableNodes = [Ca;Cb;q;Fr;T;Tc;T0;Tc0;Cb_sp;T_sp;LiminfT;LiminfCb;
                    Liminfq;LiminfFr;LimsupT;LimsupCb;Limsupq;LimsupFr;
                    p_Ca;p_Cb;p_Cc;p_Cd;p_Fr];
end

%% Creacción de nodos de escritura
function writableNodes = CreateWritableNodes(topNodes)
    % Creacion de nodos para escribir datos
    uq1  = findNodeByName(topNodes, 'uq[1]' , '-once');
    uFr1 = findNodeByName(topNodes, 'uqc[1]', '-once');
    
    writableNodes = [uq1; uFr1];
end

%% Llamada al MPC
function control_actions = RunMA(readNodes)

    Ca = readNodes(1);
    Cb = readNodes(2);
    q  = readNodes(3);
    Fr = readNodes(4);
    T  = readNodes(5);
    Tc = readNodes(6);
    T0 = readNodes(7);
    Tc0 = readNodes(8);
    Cb_sp = readNodes(9);
    T_sp  = readNodes(10);
    LiminfT  = readNodes(11);
    LiminfCb = readNodes(12);
    Liminfq  = readNodes(13);
    LiminfFr = readNodes(14);
    LimsupT  = readNodes(15);
    LimsupCb = readNodes(16);
    Limsupq  = readNodes(17);
    LimsupFr = readNodes(18);
    p_Ca = readNodes(19);
    p_Cb = readNodes(20);
    p_Cc = readNodes(21);
    p_Cd = readNodes(22);
    p_Fr = readNodes(23);
    
    q = 1;
    qc = 15;
    control_actions = [q; qc];
end

