// ═══════════════════════════════════════════════════════════════
//  D&D 5e Party Server  —  ws://localhost:3002
//  Starten: npm run party
// ═══════════════════════════════════════════════════════════════

import { WebSocketServer, WebSocket } from 'ws';
import { createServer } from 'http';

const PORT = 3002;

// rooms: { [code]: { members: Map<ws, player> } }
const rooms = new Map();

// Generate a short, readable room code
function genCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 5; i++) code += chars[Math.floor(Math.random() * chars.length)];
  // Ensure uniqueness
  if (rooms.has(code)) return genCode();
  return code;
}

// Broadcast to all members of a room EXCEPT the sender (or to all if sender=null)
function broadcast(roomCode, msg, except = null) {
  const room = rooms.get(roomCode);
  if (!room) return;
  const data = JSON.stringify(msg);
  room.members.forEach((player, ws) => {
    if (ws !== except && ws.readyState === WebSocket.OPEN) {
      ws.send(data);
    }
  });
}

// Send a complete party snapshot to all members
function sendPartyState(roomCode) {
  const room = rooms.get(roomCode);
  if (!room) return;
  const members = [];
  room.members.forEach((player) => {
    members.push({
      id:       player.id,
      name:     player.name,
      cls:      player.cls,
      race:     player.race,
      lv:       player.lv,
      hp:       player.hp,
      maxHp:    player.maxHp,
      ac:       player.ac,
      stats:    player.stats,
      fs:       player.fs,
      icon:     player.icon,
      pb:       player.pb,
      bg:       player.bg,
      align:    player.align,
      isOnline: true,
      joinedAt: player.joinedAt,
    });
  });
  const msg = { type: 'PARTY_STATE', members, roomCode };
  broadcast(roomCode, msg);
}

// HTTP server for health checks / CORS preflight
const http = createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.url === '/health') {
    const roomCount   = rooms.size;
    const playerCount = [...rooms.values()].reduce((s, r) => s + r.members.size, 0);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, rooms: roomCount, players: playerCount }));
  } else {
    res.writeHead(404);
    res.end();
  }
});

const wss = new WebSocketServer({ server: http });

wss.on('connection', (ws) => {
  let currentRoom = null;
  let playerId    = crypto.randomUUID();

  ws.on('message', (raw) => {
    let msg;
    try { msg = JSON.parse(raw); } catch { return; }

    switch (msg.type) {

      // ── Neue Party erstellen ──────────────────────────────────
      case 'CREATE_PARTY': {
        const code = genCode();
        rooms.set(code, { members: new Map() });
        const player = {
          id: playerId, ...msg.char,
          joinedAt: new Date().toISOString(),
        };
        rooms.get(code).members.set(ws, player);
        currentRoom = code;
        ws.send(JSON.stringify({ type: 'PARTY_CREATED', code, playerId }));
        sendPartyState(code);
        console.log(`[+] Party ${code} created by ${msg.char?.name || '?'}`);
        break;
      }

      // ── Bestehender Party beitreten ──────────────────────────
      case 'JOIN_PARTY': {
        const code = msg.code?.toUpperCase().trim();
        if (!rooms.has(code)) {
          ws.send(JSON.stringify({ type: 'ERROR', msg: `Party "${code}" nicht gefunden.` }));
          return;
        }
        const room = rooms.get(code);
        if (room.members.size >= 8) {
          ws.send(JSON.stringify({ type: 'ERROR', msg: 'Party voll (max. 8 Spieler).' }));
          return;
        }
        const player = {
          id: playerId, ...msg.char,
          joinedAt: new Date().toISOString(),
        };
        room.members.set(ws, player);
        currentRoom = code;
        ws.send(JSON.stringify({ type: 'JOINED_PARTY', code, playerId }));
        // Notify others
        broadcast(code, {
          type: 'PLAYER_JOINED',
          player: { id: playerId, name: msg.char?.name, icon: msg.char?.icon },
        }, ws);
        sendPartyState(code);
        console.log(`[+] ${msg.char?.name || '?'} joined ${code}`);
        break;
      }

      // ── Charakter-Daten aktualisieren (HP, etc.) ─────────────
      case 'UPDATE_CHAR': {
        if (!currentRoom || !rooms.has(currentRoom)) return;
        const room   = rooms.get(currentRoom);
        const player = room.members.get(ws);
        if (!player) return;
        Object.assign(player, msg.char);
        sendPartyState(currentRoom);
        break;
      }

      // ── Chat-Nachricht senden ─────────────────────────────────
      case 'CHAT_MSG': {
        if (!currentRoom || !rooms.has(currentRoom)) return;
        const room   = rooms.get(currentRoom);
        const player = room.members.get(ws);
        const chatMsg = {
          type:    'CHAT_MSG',
          id:      Date.now(),
          from:    player?.name || '?',
          fromId:  playerId,
          to:      msg.to || null,   // null = everyone, otherwise playerId
          text:    String(msg.text || '').slice(0, 500),
          ts:      new Date().toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }),
          secret:  !!msg.to,
        };
        // Send to everyone in room (clients filter by toId themselves)
        broadcast(currentRoom, chatMsg);
        // Also echo back to sender
        ws.send(JSON.stringify(chatMsg));
        break;
      }

      // ── Würfelwurf teilen ─────────────────────────────────────
      case 'DICE_ROLL': {
        if (!currentRoom) return;
        const room   = rooms.get(currentRoom);
        const player = room.members.get(ws);
        const rollMsg = {
          type:   'DICE_ROLL',
          from:   player?.name || '?',
          dice:   msg.dice,
          result: msg.result,
          total:  msg.total,
          ts:     new Date().toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }),
        };
        broadcast(currentRoom, rollMsg);
        ws.send(JSON.stringify(rollMsg));
        break;
      }

      // ── Party verlassen ───────────────────────────────────────
      case 'LEAVE_PARTY': {
        if (currentRoom && rooms.has(currentRoom)) {
          const room   = rooms.get(currentRoom);
          const player = room.members.get(ws);
          room.members.delete(ws);
          if (room.members.size === 0) {
            rooms.delete(currentRoom);
            console.log(`[-] Room ${currentRoom} deleted (empty)`);
          } else {
            broadcast(currentRoom, {
              type: 'PLAYER_LEFT',
              playerId,
              name: player?.name,
            });
            sendPartyState(currentRoom);
          }
        }
        currentRoom = null;
        ws.send(JSON.stringify({ type: 'LEFT_PARTY' }));
        break;
      }

      case 'PING':
        ws.send(JSON.stringify({ type: 'PONG' }));
        break;
    }
  });

  ws.on('close', () => {
    if (currentRoom && rooms.has(currentRoom)) {
      const room   = rooms.get(currentRoom);
      const player = room.members.get(ws);
      room.members.delete(ws);
      if (room.members.size === 0) {
        rooms.delete(currentRoom);
        console.log(`[-] Room ${currentRoom} deleted (empty after disconnect)`);
      } else {
        broadcast(currentRoom, {
          type: 'PLAYER_LEFT',
          playerId,
          name: player?.name,
        });
        sendPartyState(currentRoom);
      }
    }
  });

  ws.on('error', () => {});
});

http.listen(PORT, () => {
  console.log(`\n⚔️  D&D Party Server läuft auf ws://localhost:${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health\n`);
});
