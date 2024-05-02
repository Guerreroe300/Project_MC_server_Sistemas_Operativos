--libraries
local component = require("component")
local event = require("event")

local modem = component.modem

local thread = require("thread")

local serialization = require("serialization")

--some random vars
modem.open(420)

local server = "be6bc090-73ac-414e-9875-d492c5c35566"

messageBacklog = {}

-- functionssssss
local signal
local packet
function handlePackets()
  while true do
    print("waiting")
        
    _,_,_,_,_,signal,packet = event.pull("modem")
      
    print(signal)
    if signal == "UPDATE" then--connect just has the signal as mesage
      messageBacklog = serialization.unserialize(packet) 
      --for k,v in pairs(messageBacklog) do
      --  print(k)
      --  print(v)
      --end
      print("MESSAGE RECIEVED")  
      
    elseif signal == "DISCONNECT" then--disconnect has the signal and the id
      print("DICONNECTED")
      break
    end  
  end
end

--handle first connection
local recieveBacklog
local ID
local signal
local flag = false
modem.send(server, 420, "CONNECT")

_,_,recieverAdress,_,_,signal,ID, recieveBacklog = event.pull("modem")

if(signal == "CONFIRMED") then
  flag = true
end

messageBacklog = serialization.unserialize(recieveBacklog)

print("handle create")
local handle = thread.create(handlePackets)
print("done create andle")
--menu
local menu = [[Menu de Mensajes:
1) Enviar mensajes
2) Enseñar el backlog de mensajes
3) Desconectar
4) Exit
4532) Matar server]]

local opc
local input
print(flag)
while flag do
  print(menu)
  opc = io.read("*n")

  if opc == 1 then
    print("Que desea enviar: ")
    --input = io.read()
    repeat input = io.read() until input:match "%S"

    modem.send(server, 420, "MESSAGE", ID, input)
  elseif opc == 2 then
    --print(messageBacklog)
    for k,v in pairs(messageBacklog) do
      print(k)
      print(v)
    end
  elseif opc == 3 then
    modem.send(server, 420, "DISCONNECT", ID)
  elseif opc == 4 then
    break
  elseif opc == 4532 then
    modem.send(server, 420, "SHUTDOWN")
  end
end