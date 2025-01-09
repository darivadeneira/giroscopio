import asyncio
import websockets
import os

async def handle_client(websocket):
    async for message in websocket:
        print(f"Comando recibido: {message}")
        if message == "OPEN_BROWSER":
            os.system("start https://www.google.com")  # Abrir navegador.
            await websocket.send("Comando OPEN_BROWSER ejecutado")  # Enviar confirmación al cliente.
        elif message == "OPEN_WORD":
            os.system("start winword")  # Abrir Microsoft Word.
            await websocket.send("Comando OPEN_WORD ejecutado")  # Enviar confirmación al cliente.
        elif message == "PLAY_MEDIA":
            os.system("start wmplayer")  # Reproducir multimedia.
            await websocket.send("Comando PLAY_MEDIA ejecutado")  # Enviar confirmación al cliente.

async def main():
    async with websockets.serve(handle_client, "0.0.0.0", 12345):
        print("Servidor WebSocket iniciado en el puerto 12345.")
        await asyncio.Future()  # Mantener el servidor corriendo.

asyncio.run(main())
