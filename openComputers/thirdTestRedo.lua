--Asi se importan librerias, en este caso modem es una de openComputers
local component = require("component")
local event = require("event")

local modem = component.modem

local thread = require("thread")

local serialization = require("serialization")

local temp

--Abrir puerto, este es el de default para login
modem.open(420)


--we need a list or some way to keep track of clients
--current idea is a list with ids along with a dictionary
-- the dictionary will have the ids as keys and will have a list as value which has; id, username, address, etc
local idList = {} -- use as list
local idInfo = {} -- use as dictionary --id = {adress, username}

--For testing purposes the message backlog will be a list and temporal per instance, we can implement a permanent system
local messageBacklog = {}
--format will be time_sent = {user or id sentby, message}


--Here imma define the functions we using
--we need one that will tell the rest of the clients to update, gives em updated backlog
function updateClients(except)
  print("updating clients")
  for i, info in pairs(idInfo)do
    --print(info[1])
    modem.send(info[1], 420, "UPDATE", serialization.serialize(messageBacklog))
    print("sent to "..info[1])
  end
end

--mesage handlingm relies on update clients
function messageHandle(id, mes)
  print("hnadling message")
  --time = os.date("*t")
  --messageBacklog[time] = {id, mes, "exampleUsername"}
  table.insert(messageBacklog, id)
  table.insert(messageBacklog, mes)
  updateClients(id)
end

--we need one that will check for an closed port and opening it
function idChecker()
  print("checking id")
  local found = false
  local num
  while found == false do
    num = math.random(1000)
    found = true
    for _, v in pairs(idList) do
      if v == x then 
        found = false 
      end
    end
  end
  return tostring(num)
end

--handles incoming connections
function connectHandle(id, address)
  print("handling connection")
  table.insert(idList, id)
  local tempTable = {address, "exampleName"}
  
  print(tempTable)
  idInfo[id] = tempTable
  print("done with handle")
end

--a function to handle disconnection
function disconectClient(id)
  print("handling disconnection")
  local count = 1
  for i in pairs(idList)do
    if i == id then
      table.remove(idList, count)
      break
    end
    count = count + 1
  end

  for i in pairs(idInfo)do
    if i == id then
      table.remove(idInfo, count)
      break
    end
    count = count + 1
  end
end

function shutdownAll()
  print("shutting down")
  for i, info in pairs(idInfo)do
    modem.send(info[1], 420, "DISCONNECT")
  end
end

--if done by server this will simply tell the clients that we jover here

--finally we need the actuall main connect disconnect thread that recieves a signal and will use the ones above
local signal
local newID
local recieverAdress
local ID
local message
while true do
  print("waiting")
  
  _,_,recieverAdress,_,_,signal,ID, message = event.pull("modem")

  if signal == "CONNECT" then --connect just has the signal as mesage
    newID = idChecker()  
    
    connectHandle(newID, recieverAdress)

    modem.send(recieverAdress, 420, "CONFIRMED", newID, serialization.serialize(messageBacklog))

  elseif signal == "DISCONNECT" then  --disconnect has the signal and the id
    disconnectClient(ID)
    modem.send(recieverAdress, 420, "DISCONNECT")
  elseif signal == "MESSAGE" then
    messageHandle(ID, message)
  elseif signal == "SHUTDOWN" then
    shutdownAll()
    break
  end  

  print(message)
  print(recieverAdress)
  --print(messageBacklog)
  for k,v in pairs(messageBacklog) do
    print(k)
    print(v)
  end


  --break
  
end

--okkk
----ok part 222
----okkkkk part 3