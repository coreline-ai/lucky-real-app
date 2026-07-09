import { formatProviderError, resolveGameReadings } from './providers';
import type { BirthFormInput, GameReadings, PillarSourceMeta } from './providers/types';

// --- Type Definitions ---
type Ohaeng = '목' | '화' | '토' | '금' | '수';

interface Card {
  id: string;
  element: Ohaeng;
  name: string;
  description: string;
}

// --- Constants ---
const OHAENG_ENGLISH: Record<Ohaeng, string> = {
  '목': 'wood',
  '화': 'fire',
  '토': 'earth',
  '금': 'metal',
  '수': 'water',
};

const OHAENG_EMOJI: Record<Ohaeng, string> = {
  '목': '🌲',
  '화': '🔥',
  '토': '⛰️',
  '금': '⚔️',
  '수': '💧',
};

const OHAENG_DESC: Record<Ohaeng, string> = {
  '목': '나무의 힘. 흙(土)을 극하며, 불(火)을 생(生)합니다.',
  '화': '불꽃의 힘. 쇠(金)를 극하며, 흙(土)을 생(生)합니다.',
  '토': '대지의 힘. 물(水)을 극하며, 쇠(金)를 생(生)합니다.',
  '금': '바위/쇠의 힘. 나무(木)를 극하며, 물(水)을 생(生)합니다.',
  '수': '바다/물의 힘. 불(火)을 극하며, 나무(木)를 생(生)합니다.',
};

const GAN_OHAENG: Record<string, Ohaeng> = {
  '甲': '목', '乙': '목',
  '丙': '화', '丁': '화',
  '戊': '토', '己': '토',
  '庚': '금', '辛': '금',
  '壬': '수', '癸': '수',
};

const BRANCH_OHAENG: Record<string, Ohaeng> = {
  '寅': '목', '卯': '목',
  '巳': '화', '午': '화',
  '辰': '토', '戌': '토', '丑': '토', '未': '토',
  '申': '금', '酉': '금',
  '亥': '수', '子': '수',
};

// 상생 (생) 매핑: key가 value를 생함
const OHAENG_SAENG: Record<Ohaeng, Ohaeng> = {
  '목': '화',
  '화': '토',
  '토': '금',
  '금': '수',
  '수': '목',
};

// 상극 (극) 매핑: key가 value를 극함
const OHAENG_GEUK: Record<Ohaeng, Ohaeng> = {
  '목': '토',
  '토': '수',
  '수': '화',
  '화': '금',
  '금': '목',
};

// --- Game State ---
let playerName = '홍길동';
let playerGender: 'male' | 'female' = 'male';
let playerGanJi = '甲子';
let playerOhaengs: Ohaeng[] = ['목', '수'];

let bossName = '일진수호마왕';
let bossGanJi = '庚午';
let bossOhaengs: Ohaeng[] = ['금', '화'];
let sourceMetas: PillarSourceMeta[] = [];
let fallbackReason: string | undefined;

let playerHand: Card[] = [];
let bossHand: Card[] = [];
let slottedCards: (Card | null)[] = [null, null, null]; // Slotted in Round 1, 2, 3

let playerHP = 100;
let bossHP = 100;
let currentRound = 1;
let battleHistory: string[] = [];

// --- DOM Elements ---
const setupScreen = document.getElementById('setup-screen')!;
const lobbyScreen = document.getElementById('lobby-screen')!;
const battleScreen = document.getElementById('battle-screen')!;
const resultModal = document.getElementById('result-modal')!;

const setupForm = document.getElementById('setup-form') as HTMLFormElement;
const btnSummon = document.getElementById('btn-summon') as HTMLButtonElement;
const inputHour = document.getElementById('input-hour') as HTMLSelectElement;
const inputMinute = document.getElementById('input-minute') as HTMLSelectElement;
const sourceBadgeEl = document.getElementById('source-badge')!;
const statusMessageEl = document.getElementById('status-message')!;
const fallbackBannerEl = document.getElementById('fallback-banner')!;
const mcpProofEl = document.getElementById('mcp-proof')!;

const playerGanJiEl = document.getElementById('player-ganji')!;
const playerNameEl = document.getElementById('player-name-display')!;
const playerOhaengTagsEl = document.getElementById('player-ohaeng-tags')!;

const bossGanJiEl = document.getElementById('boss-ganji')!;
const bossNameEl = document.getElementById('boss-name-display')!;
const bossOhaengTagsEl = document.getElementById('boss-ohaeng-tags')!;

const playerHandEl = document.getElementById('player-hand')!;
const btnEnterBattle = document.getElementById('btn-enter-battle') as HTMLButtonElement;

// Arena elements
const arenaBossName = document.getElementById('arena-boss-name')!;
const arenaPlayerName = document.getElementById('arena-player-name')!;
const arenaPlayerGanJi = document.getElementById('arena-player-ganji')!;
const bossHpCurrent = document.getElementById('boss-hp-current')!;
const playerHpCurrent = document.getElementById('player-hp-current')!;
const bossHpBar = document.getElementById('boss-hp-bar')!;
const playerHpBar = document.getElementById('player-hp-bar')!;

const btnFight = document.getElementById('btn-fight') as HTMLButtonElement;
const btnNextRound = document.getElementById('btn-next-round') as HTMLButtonElement;

// Modal elements
const modalResultIcon = document.getElementById('modal-result-icon')!;
const modalResultTitle = document.getElementById('modal-result-title')!;
const modalResultSummary = document.getElementById('modal-result-summary')!;
const modalResultDetails = document.getElementById('modal-result-details')!;
const btnModalRestart = document.getElementById('btn-modal-restart') as HTMLButtonElement;

// --- Initialize dropdowns ---
function initDropdowns() {
  for (let h = 0; h < 24; h++) {
    const opt = document.createElement('option');
    opt.value = h.toString();
    opt.textContent = `${h.toString().padStart(2, '0')}시`;
    inputHour.appendChild(opt);
  }
  for (let m = 0; m < 60; m++) {
    const opt = document.createElement('option');
    opt.value = m.toString();
    opt.textContent = `${m.toString().padStart(2, '0')}분`;
    inputMinute.appendChild(opt);
  }
}

// Helper to generate a random element
function getRandomElement(): Ohaeng {
  const elements: Ohaeng[] = ['목', '화', '토', '금', '수'];
  return elements[Math.floor(Math.random() * elements.length)];
}

// Generate Card Info
function createCard(element: Ohaeng, id: string): Card {
  return {
    id,
    element,
    name: `${element}(${OHAENG_EMOJI[element]}) 수호신`,
    description: OHAENG_DESC[element],
  };
}

function sourceLabel(meta: PillarSourceMeta | undefined): string {
  if (meta?.source === 'mcp') return 'via manseryeok-mcp';
  if (meta?.source === 'mcp-bridge') return 'via mcp-bridge';
  if (meta?.source === 'local') return 'via local-engine';
  return 'source: 준비 중';
}

function sourceClass(meta: PillarSourceMeta | undefined): string {
  if (meta?.source === 'mcp') return 'source-badge source-mcp';
  if (meta?.source === 'mcp-bridge') return 'source-badge source-bridge';
  if (meta?.source === 'local') return 'source-badge source-local';
  return 'source-badge source-idle';
}

function setStatus(message: string, tone: 'info' | 'warning' | 'error' = 'info') {
  statusMessageEl.textContent = message;
  statusMessageEl.className = `status-message status-${tone}`;
}

function clearStatus() {
  statusMessageEl.textContent = '';
  statusMessageEl.className = 'status-message';
}

function setLoading(isLoading: boolean) {
  btnSummon.disabled = isLoading;
  btnSummon.textContent = isLoading ? 'MCP 계산 중...' : '수호신 소환하기 (Summon)';
  if (isLoading) {
    sourceBadgeEl.className = 'source-badge source-loading';
    sourceBadgeEl.textContent = 'source: MCP initialize → tools/call';
    setStatus('manseryeok-mcp 연결 및 결정론 계산을 확인 중입니다.', 'info');
  }
}

function ohaengFromGanJi(gan: string, ji: string, fallback: Ohaeng[]): Ohaeng[] {
  return [GAN_OHAENG[gan] ?? fallback[0], BRANCH_OHAENG[ji] ?? fallback[1]];
}

function applyReadings(readings: GameReadings) {
  const { player, boss } = readings;
  playerGanJi = player.pillar.ganji;
  bossGanJi = boss.pillar.ganji;
  playerOhaengs = ohaengFromGanJi(player.pillar.gan, player.pillar.ji, ['목', '수']);
  bossOhaengs = ohaengFromGanJi(boss.pillar.gan, boss.pillar.ji, ['금', '화']);
  sourceMetas = [player.meta, boss.meta];
  fallbackReason = readings.fallbackReason;
}

function updateProofUI() {
  const primaryMeta = sourceMetas[0];
  sourceBadgeEl.className = sourceClass(primaryMeta);
  sourceBadgeEl.textContent = sourceLabel(primaryMeta);

  const tools = sourceMetas.map((meta) => meta.tool).filter(Boolean).join(', ') || 'local-engine';
  const engineVersion = sourceMetas.find((meta) => meta.engineVersion)?.engineVersion ?? '-';
  const ruleVersion = sourceMetas.find((meta) => meta.ruleVersion)?.ruleVersion ?? '-';
  mcpProofEl.textContent = `${sourceLabel(primaryMeta)} · tools: ${tools} · engine ${engineVersion} · rule ${ruleVersion}`;

  if (fallbackReason) {
    fallbackBannerEl.hidden = false;
    fallbackBannerEl.textContent = `MCP 호출 실패로 local-engine 폴백을 사용했습니다: ${fallbackReason}`;
    setStatus('MCP 실패를 감지해 로컬 엔진으로 데모를 계속합니다.', 'warning');
  } else {
    fallbackBannerEl.hidden = true;
    fallbackBannerEl.textContent = '';
    clearStatus();
  }
}

// Initialize setup listener
function setupGameInit() {
  setupForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    const name = (document.getElementById('input-name') as HTMLInputElement).value.trim() || '홍길동';
    const gender = (document.getElementById('input-gender') as HTMLSelectElement).value as 'male' | 'female';
    const dateVal = (document.getElementById('input-date') as HTMLInputElement).value;
    const hourVal = inputHour.value;
    const minVal = inputMinute.value;

    if (!dateVal) {
      setStatus('생년월일을 입력해 주세요.', 'error');
      return;
    }

    const [year, month, day] = dateVal.split('-').map(Number);
    const hour = hourVal !== '' ? Number(hourVal) : null;
    const minute = hour !== null && minVal !== '' ? Number(minVal) : null;
    const input: BirthFormInput = { year, month, day, hour, minute, gender };

    setLoading(true);
    try {
      const readings = await resolveGameReadings(input);
      playerName = name;
      playerGender = gender;
      applyReadings(readings);

      const [pGanOhaeng, pJiOhaeng] = playerOhaengs;
      const [bGanOhaeng, bJiOhaeng] = bossOhaengs;

      // Player gets Day Gan card, Day Ji card, and 1 random card.
      playerHand = [
        createCard(pGanOhaeng, 'player-1'),
        createCard(pJiOhaeng, 'player-2'),
        createCard(getRandomElement(), 'player-3'),
      ];

      // Boss gets Boss Gan card, Boss Ji card, and 1 random card.
      bossHand = [
        createCard(bGanOhaeng, 'boss-1'),
        createCard(bJiOhaeng, 'boss-2'),
        createCard(getRandomElement(), 'boss-3'),
      ];

      // With exactly three cards and three rounds, start with a playable order.
      slottedCards = [...playerHand];
      btnEnterBattle.disabled = false;

      updateProofUI();
      showLobby();
    } catch (error) {
      sourceBadgeEl.className = 'source-badge source-error';
      sourceBadgeEl.textContent = 'source: MCP error';
      setStatus(`소환 실패: ${formatProviderError(error)}`, 'error');
    } finally {
      setLoading(false);
    }
  });
}

// Display Lobby Screen
function showLobby() {
  // Update texts
  playerNameEl.textContent = playerName;
  playerGanJiEl.textContent = playerGanJi;
  
  // Set avatar color/symbol based on player primary element
  const playerPrimary = playerOhaengs[0];
  const pAvatar = document.getElementById('player-avatar')!;
  pAvatar.textContent = OHAENG_EMOJI[playerPrimary];
  pAvatar.style.borderColor = `var(--color-${OHAENG_ENGLISH[playerPrimary]})`;
  pAvatar.style.boxShadow = `0 0 20px var(--color-${OHAENG_ENGLISH[playerPrimary]}-glow)`;

  playerOhaengTagsEl.innerHTML = '';
  playerOhaengs.forEach(oh => {
    const span = document.createElement('span');
    span.className = `tag tag-${OHAENG_ENGLISH[oh]}`;
    span.textContent = `${oh}(${OHAENG_EMOJI[oh]})`;
    playerOhaengTagsEl.appendChild(span);
  });

  // Boss Info
  bossNameEl.textContent = '일진 보스';
  bossGanJiEl.textContent = bossGanJi;

  const bossPrimary = bossOhaengs[0];
  const bAvatar = document.getElementById('boss-avatar')!;
  bAvatar.textContent = OHAENG_EMOJI[bossPrimary];
  bAvatar.style.borderColor = `var(--color-${OHAENG_ENGLISH[bossPrimary]})`;
  bAvatar.style.boxShadow = `0 0 20px var(--color-${OHAENG_ENGLISH[bossPrimary]}-glow)`;

  bossOhaengTagsEl.innerHTML = '';
  bossOhaengs.forEach(oh => {
    const span = document.createElement('span');
    span.className = `tag tag-${OHAENG_ENGLISH[oh]}`;
    span.textContent = `${oh}(${OHAENG_EMOJI[oh]})`;
    bossOhaengTagsEl.appendChild(span);
  });

  // Display Hand
  renderHand();

  switchScreen(setupScreen, lobbyScreen);
}

// Render player hand for slot assignment
function renderHand() {
  playerHandEl.innerHTML = '';
  playerHand.forEach(card => {
    const slotIndex = slottedCards.indexOf(card);
    const isSlotted = slotIndex !== -1;
    const cardEl = document.createElement('div');
    cardEl.className = `game-card flipped card-${OHAENG_ENGLISH[card.element]} ${isSlotted ? 'selected' : ''}`;
    cardEl.innerHTML = `
      ${isSlotted ? `<div class="slot-order-badge">R${slotIndex + 1}</div>` : ''}
      <div class="card-inner">
        <div class="card-back">☯️</div>
        <div class="card-front">
          <div class="card-header">
            <span>수호신</span>
            <span>${OHAENG_EMOJI[card.element]}</span>
          </div>
          <div class="card-symbol">${OHAENG_EMOJI[card.element]}</div>
          <div class="card-element-name">${card.element}</div>
          <div class="card-desc">${card.description}</div>
        </div>
      </div>
    `;

    // Click to assign to empty round slots
    cardEl.addEventListener('click', () => {
      if (isSlotted) {
        // Remove from slot
        const index = slottedCards.indexOf(card);
        if (index !== -1) {
          slottedCards[index] = null;
        }
      } else {
        // Place in first empty slot
        const emptyIdx = slottedCards.indexOf(null);
        if (emptyIdx !== -1) {
          slottedCards[emptyIdx] = card;
        }
      }
      renderHand();
      updateSlottedSlots();
    });

    playerHandEl.appendChild(cardEl);
  });
}

// Update the visible slotted card slots in the lobby (or check if ready)
function updateSlottedSlots() {
  // If all 3 slots are filled, enable entering battle
  const allFilled = slottedCards.every(c => c !== null);
  btnEnterBattle.disabled = !allFilled;
}

// Switch screen utility
function switchScreen(from: HTMLElement, to: HTMLElement) {
  from.classList.remove('active');
  from.style.display = 'none';
  to.style.display = 'block';
  setTimeout(() => {
    to.classList.add('active');
  }, 50);
}

// --- Setup entering battle ---
btnEnterBattle.addEventListener('click', () => {
  if (!slottedCards.every(Boolean)) return;

  arenaPlayerName.textContent = playerName;
  arenaPlayerGanJi.textContent = playerGanJi;
  arenaBossName.textContent = bossGanJi;

  // Initialize Arena slots with slotted player cards
  for (let i = 0; i < 3; i++) {
    const card = slottedCards[i]!;
    const playerSlot = document.getElementById(`player-card-slot-${i + 1}`)!;
    playerSlot.className = `slot-card player-slot card-${OHAENG_ENGLISH[card.element]}`;
    playerSlot.innerHTML = `
      <div class="card-inner">
        <div class="card-back">☯️</div>
        <div class="card-front">
          <div class="card-header">
            <span>수호신</span>
            <span>${OHAENG_EMOJI[card.element]}</span>
          </div>
          <div class="card-symbol">${OHAENG_EMOJI[card.element]}</div>
          <div class="card-element-name">${card.element}</div>
        </div>
      </div>
    `;

    // Boss slots start as face down
    const bossSlot = document.getElementById(`boss-card-slot-${i + 1}`)!;
    bossSlot.className = 'slot-card boss-slot';
    bossSlot.innerHTML = `<div class="card-back">❓</div>`;

    // Clear impact results
    document.getElementById(`impact-slot-${i + 1}`)!.innerHTML = '';
    document.getElementById(`round-result-${i + 1}`)!.textContent = '-';
  }

  // Reset HP & Rounds
  playerHP = 100;
  bossHP = 100;
  currentRound = 1;
  battleHistory = [];

  updateHPBars();

  btnFight.style.display = 'block';
  btnFight.disabled = false;
  btnNextRound.style.display = 'none';

  switchScreen(lobbyScreen, battleScreen);
});

// Update HP displays and bars
function updateHPBars() {
  bossHpCurrent.textContent = Math.max(0, bossHP).toString();
  playerHpCurrent.textContent = Math.max(0, playerHP).toString();

  bossHpBar.style.width = `${Math.max(0, bossHP)}%`;
  playerHpBar.style.width = `${Math.max(0, playerHP)}%`;
}

// --- Battle Round Logic ---
btnFight.addEventListener('click', () => {
  btnFight.disabled = true;
  executeRound();
});

btnNextRound.addEventListener('click', () => {
  executeRound();
});

function executeRound() {
  const rIdx = currentRound - 1;
  const pCard = slottedCards[rIdx]!;
  const bCard = bossHand[rIdx]!;

  // 1. Reveal boss card with flip animation
  const bossSlot = document.getElementById(`boss-card-slot-${currentRound}`)!;
  bossSlot.className = `slot-card boss-slot card-${OHAENG_ENGLISH[bCard.element]} flipped`;
  bossSlot.innerHTML = `
    <div class="card-inner">
      <div class="card-back">❓</div>
      <div class="card-front">
        <div class="card-header">
          <span>일진 보스</span>
          <span>${OHAENG_EMOJI[bCard.element]}</span>
        </div>
        <div class="card-symbol">${OHAENG_EMOJI[bCard.element]}</div>
        <div class="card-element-name">${bCard.element}</div>
      </div>
    </div>
  `;

  // Trigger flip animation classes on player card as well (to keep layout synced)
  const playerSlot = document.getElementById(`player-card-slot-${currentRound}`)!;
  playerSlot.classList.add('flipped');

  // 2. Calculate damage according to rules
  let pDamage = 0;
  let bDamage = 0;
  let pHeal = 0;
  let bHeal = 0;
  let resultMsg = '';

  const pEl = pCard.element;
  const bEl = bCard.element;

  if (OHAENG_GEUK[pEl] === bEl) {
    // Player controls Boss (상극 - 크리티컬 공격!)
    pDamage = 35;
    resultMsg = `수호신 [${pEl}]이 보스 [${bEl}]을 극(克)함! 치명타 ${pDamage} 피해!`;
  } else if (OHAENG_GEUK[bEl] === pEl) {
    // Boss controls Player (상극 - 크리티컬 공격 피격!)
    bDamage = 35;
    resultMsg = `보스 [${bEl}]가 수호신 [${pEl}]을 극(克)함! 피격 ${bDamage} 피해!`;
  } else if (OHAENG_SAENG[pEl] === bEl) {
    // Player generates Boss (상생 - 보스 힐 및 소량 데미지)
    pDamage = 15;
    bHeal = 15;
    resultMsg = `수호신 [${pEl}]이 보스 [${bEl}]을 생(生)함! 보스 체력 ${bHeal} 회복 및 ${pDamage} 피해.`;
  } else if (OHAENG_SAENG[bEl] === pEl) {
    // Boss generates Player (상생 - 플레이어 힐 및 소량 데미지)
    bDamage = 15;
    pHeal = 15;
    resultMsg = `보스 [${bEl}]가 수호신 [${pEl}]을 생(生)함! 아군 체력 ${pHeal} 회복 및 ${bDamage} 피해.`;
  } else if (pEl === bEl) {
    // Same elements (비화)
    pDamage = 20;
    bDamage = 20;
    resultMsg = `동일한 오행 [${pEl}] 격돌! 서로 ${pDamage} 피해.`;
  } else {
    // No direct relation
    pDamage = 20;
    bDamage = 20;
    resultMsg = `서로 무난한 격돌. 양측 ${pDamage} 피해.`;
  }

  // Apply values
  bossHP = Math.max(0, bossHP - pDamage + bHeal);
  playerHP = Math.max(0, playerHP - bDamage + pHeal);
  battleHistory.push(resultMsg);

  // 3. Show floating numbers & animations
  const impactEl = document.getElementById(`impact-slot-${currentRound}`)!;
  
  if (pDamage > 0) {
    const floatD = document.createElement('div');
    floatD.className = 'damage-float';
    floatD.textContent = `-${pDamage}`;
    floatD.style.top = '-20px';
    impactEl.appendChild(floatD);
    bossSlot.classList.add('shake');
  }
  if (bHeal > 0) {
    const floatH = document.createElement('div');
    floatH.className = 'heal-float';
    floatH.textContent = `+${bHeal}`;
    floatH.style.top = '-20px';
    impactEl.appendChild(floatH);
  }

  if (bDamage > 0) {
    const floatD = document.createElement('div');
    floatD.className = 'damage-float';
    floatD.textContent = `-${bDamage}`;
    floatD.style.bottom = '-20px';
    impactEl.appendChild(floatD);
    playerSlot.classList.add('shake');
  }
  if (pHeal > 0) {
    const floatH = document.createElement('div');
    floatH.className = 'heal-float';
    floatH.textContent = `+${pHeal}`;
    floatH.style.bottom = '-20px';
    impactEl.appendChild(floatH);
  }

  // Update round results
  document.getElementById(`round-result-${currentRound}`)!.textContent = resultMsg;
  updateHPBars();

  // Clean shake classes after animation
  setTimeout(() => {
    bossSlot.classList.remove('shake');
    playerSlot.classList.remove('shake');
  }, 600);

  // 4. Check ending conditions
  if (playerHP <= 0 || bossHP <= 0 || currentRound === 3) {
    setTimeout(showEndGameSummary, 1500);
  } else {
    currentRound++;
    btnFight.style.display = 'none';
    btnNextRound.style.display = 'block';
  }
}

// Show End Game Modal Popup
function showEndGameSummary() {
  let victory = false;
  
  if (playerHP > bossHP) {
    victory = true;
  }

  modalResultIcon.textContent = victory ? '🏆' : '💀';
  modalResultTitle.textContent = victory ? '대승리 (VICTORY)' : '패배 (DEFEAT)';
  
  // Highlight summary based on final HP
  if (victory) {
    modalResultSummary.textContent = `축하합니다! 보스(${bossGanJi})를 꺾고 오늘의 일진 수호 아레나를 장악했습니다. 남은 HP: ${playerHP}%`;
  } else {
    modalResultSummary.textContent = `아쉽게 패배했습니다... 보스(${bossGanJi})의 오행 압박을 버티지 못했습니다. 보스 남은 HP: ${bossHP}%`;
  }

  // Detailed round analysis
  let detailsHtml = '<ol>';
  battleHistory.forEach((h, idx) => {
    detailsHtml += `<li><strong>라운드 ${idx + 1}</strong>: ${h}</li>`;
  });
  detailsHtml += '</ol>';
  detailsHtml += `<br><p><strong>내 사주 팁:</strong> 당신은 [${playerGanJi}]일에 태어난 사주로 [${playerOhaengs.join(', ')}]의 기운이 풍부합니다. 오늘의 일진 기운은 [${bossGanJi}]으로 [${bossOhaengs.join(', ')}] 기운이 강해, 이에 어울리는 카드 상성으로 대응하시는 것이 핵심 비결입니다.</p>`;

  modalResultDetails.innerHTML = detailsHtml;
  resultModal.classList.add('active');
}

// Restart Game
btnModalRestart.addEventListener('click', () => {
  resultModal.classList.remove('active');
  switchScreen(battleScreen, setupScreen);
});

// Start application
initDropdowns();
setupGameInit();
