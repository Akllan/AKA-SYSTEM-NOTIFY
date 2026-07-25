(function() {
    'use strict';

    const DEBUG = (typeof Config !== 'undefined' && Config.Debug === true);

    const container = document.getElementById('hud-container');
    const healthFill = document.getElementById('health-fill');
    const healthText = document.getElementById('health-text');
    const healthBox = document.querySelector('.health-box');
    const foodFill = document.getElementById('food-fill');
    const foodText = document.getElementById('food-text');
    const foodBox = document.querySelector('.food-box');
    const thirstFill = document.getElementById('thirst-fill');
    const thirstText = document.getElementById('thirst-text');
    const thirstBox = document.querySelector('.thirst-box');
    const armourFill = document.getElementById('armour-fill');
    const armourText = document.getElementById('armour-text');
    const armourRow = document.getElementById('armour-row');
    const armourBox = document.getElementById('armour-box');
    const micOverlay = document.getElementById('mic-overlay');
    const vehicleSection = document.getElementById('vehicle-section');
    const vSpeed = document.getElementById('v-speed');
    const vUnit = document.getElementById('v-unit');
    const vGear = document.getElementById('v-gear');
    const vFuelText = document.getElementById('v-fuel-value');
    const vFuelFill = document.getElementById('v-fuel-fill');
    const vRpmFill = document.getElementById('v-rpm-fill');
    const vSeatbelt = document.getElementById('v-seatbelt');
    const vNitroRow = document.getElementById('v-row-nitro');
    const vNitroFill = document.getElementById('v-nitro-fill');
    const infoJob = document.getElementById('info-job-value');
    const infoGrade = document.getElementById('info-grade-value');
    const infoGradeBox = document.getElementById('info-grade');
    const infoCash = document.getElementById('info-cash-value');
    const infoBank = document.getElementById('info-bank-value');
    const infoId = document.getElementById('info-id-value');

    if (!container || !healthFill || !healthText || !healthBox ||
        !foodFill || !foodText || !foodBox ||
        !thirstFill || !thirstText || !thirstBox) {
        console.error('[aka-hud] Error crítico: Elementos del DOM del HUD no encontrados.');
        return;
    }

    const HUD_COLORS = {
        purple: { hex: '#b040e0', rgb: '176, 64, 224' },
        blue:   { hex: '#4fc3f7', rgb: '79, 195, 247' },
        yellow: { hex: '#ffeb3b', rgb: '255, 235, 59' },
        green:  { hex: '#4caf50', rgb: '76, 175, 80' },
        red:    { hex: '#ef5350', rgb: '239, 83, 80' },
        cyan:   { hex: '#00bcd4', rgb: '0, 188, 212' },
        pink:   { hex: '#ec407a', rgb: '236, 64, 122' },
        orange: { hex: '#ff9800', rgb: '255, 152, 0' },
        white:  { hex: '#ffffff', rgb: '255, 255, 255' },
    };

    function applyHudColor(name) {
        const color = HUD_COLORS[name] || HUD_COLORS.purple;
        document.documentElement.style.setProperty('--hud-color', color.hex);
        document.documentElement.style.setProperty('--hud-color-rgb', color.rgb);
        log('applyHudColor: ' + name + ' -> ' + color.hex);
    }

    function setInfo(data) {
        if (infoJob) infoJob.textContent = data.job || 'Civilian';
        if (infoGrade) infoGrade.textContent = data.grade || '';
        if (infoGradeBox) {
            if (data.grade && data.grade !== '') {
                infoGradeBox.classList.remove('hidden');
            } else {
                infoGradeBox.classList.add('hidden');
            }
        }
        if (infoCash) infoCash.textContent = data.cash || '$0';
        if (infoBank) infoBank.textContent = data.bank || '$0';
        if (infoId) infoId.textContent = data.id || '0';
        log('setInfo: job=' + (data.job || '') + ' grade=' + (data.grade || '') + ' cash=' + (data.cash || '') + ' bank=' + (data.bank || '') + ' id=' + (data.id || ''));
    }

    function log(msg) {
        if (DEBUG) console.log('[aka-hud] ' + msg);
    }

    log('JS cargado con éxito e inicializado.');

    function setHealth(health) {
        const safeHealth = Math.max(0, Math.min(100, Number(health) || 0));
        healthFill.style.width = safeHealth + '%';
        healthText.textContent = Math.round(safeHealth);

        const scale = 0.5 + (safeHealth / 100) * 0.5;
        healthBox.style.setProperty('--box-scale', scale);

        log('setHealth ejecutado: ' + safeHealth + '%');
    }

    var lastFoodScale = -1;
    function setFood(food) {
        const safeFood = Math.max(0, Math.min(100, Number(food) || 0));
        foodFill.style.width = safeFood + '%';
        foodText.textContent = Math.round(safeFood);

        const scale = 0.5 + (safeFood / 100) * 0.5;
        if (scale !== lastFoodScale) {
            foodBox.style.setProperty('--box-scale', scale);
            lastFoodScale = scale;
        }

        if (safeFood <= 0) {
            foodBox.classList.add('critical');
        } else {
            foodBox.classList.remove('critical');
        }

        log('setFood ejecutado: ' + safeFood + '%');
    }

    var lastThirstScale = -1;
    function setThirst(thirst) {
        const safeThirst = Math.max(0, Math.min(100, Number(thirst) || 0));
        thirstFill.style.width = safeThirst + '%';
        thirstText.textContent = Math.round(safeThirst);

        const scale = 0.5 + (safeThirst / 100) * 0.5;
        if (scale !== lastThirstScale) {
            thirstBox.style.setProperty('--box-scale', scale);
            lastThirstScale = scale;
        }

        if (safeThirst <= 0) {
            thirstBox.classList.add('critical');
        } else {
            thirstBox.classList.remove('critical');
        }

        log('setThirst ejecutado: ' + safeThirst + '%');
    }

    function setArmour(armour) {
        const safeArmour = Math.max(0, Math.min(100, Number(armour) || 0));

        if (armourFill && armourText) {
            armourFill.style.width = safeArmour + '%';
            armourText.textContent = Math.round(safeArmour);
        }

        if (armourRow) {
            if (safeArmour > 0) {
                armourRow.classList.remove('hidden');
            } else {
                armourRow.classList.add('hidden');
            }
        }

        log('setArmour ejecutado: ' + safeArmour + '%');
    }

    function setMic(state) {
        if (!micOverlay) return;

        if (state === 'talking') {
            micOverlay.classList.add('visible');
        } else {
            micOverlay.classList.remove('visible');
        }

        log('setMic ejecutado: ' + state);
    }

    function setVehicleData(data) {
        if (!vehicleSection) return;

        if (data.show) {
            vehicleSection.classList.add('visible');
            if (vSpeed) vSpeed.textContent = data.speed;
            if (vUnit) vUnit.textContent = data.unit || 'KM/H';

            if (vGear) {
                var gearVal = parseInt(data.gear, 10);
                vGear.textContent = (!data.speed || data.speed === 0 || gearVal === 0) ? 'N' : gearVal;
            }

            var fuel = Math.max(0, Math.min(100, Number(data.fuel) || 0));
            if (vFuelFill) vFuelFill.style.width = fuel + '%';
            if (vFuelText) vFuelText.textContent = fuel + '%';

            var rpmWidth = Math.max(0, Math.min(100, (data.rpm || 0) * 100));
            if (vRpmFill) vRpmFill.style.width = rpmWidth + '%';

            if (vSeatbelt) {
                if (data.seatbelt) {
                    vSeatbelt.classList.add('on');
                } else {
                    vSeatbelt.classList.remove('on');
                }
            }

            if (vNitroRow) {
                if (data.hasNitro) {
                    vNitroRow.classList.add('visible');
                } else {
                    vNitroRow.classList.remove('visible');
                }
            }

            if (vNitroFill && data.nitro !== undefined) {
                vNitroFill.style.width = Math.max(0, Math.min(100, (data.nitro || 0) * 100)) + '%';
            }
        } else {
            vehicleSection.classList.remove('visible');
            if (vSeatbelt) vSeatbelt.classList.remove('on');
            if (vNitroRow) vNitroRow.classList.remove('visible');
        }

        log('setVehicleData: show=' + (data.show ? 'true' : 'false') + ' speed=' + data.speed);
    }

    window.addEventListener('message', function(event) {
        const msg = event.data;
        if (!msg || !msg.action) return;

        log('NUI Message recibido: ' + msg.action);

        switch (msg.action) {
            case 'death':
                setHealth(0);
                setArmour(msg.armour || 0);
                container.classList.add('dead');
                break;
            case 'revive':
                container.classList.remove('dead');
                setHealth(msg.health);
                setArmour(msg.armour || 0);
                break;
            case 'setHealth':
                container.classList.remove('dead');
                setHealth(msg.health);
                if (msg.armour !== undefined) setArmour(msg.armour);
                break;
            case 'setArmour':
                setArmour(msg.armour);
                break;
            case 'setMic':
                setMic(msg.state);
                break;
            case 'setStatus':
                setFood(msg.food);
                setThirst(msg.thirst);
                break;
            case 'setVehicle':
                if (msg.inVehicle) {
                    container.classList.add('in-vehicle');
                } else {
                    container.classList.remove('in-vehicle');
                }
                break;
            case 'setVehicleData':
                setVehicleData(msg);
                break;
            case 'setInfo':
                setInfo(msg);
                break;
            case 'show':
                container.classList.add('visible');
                applyHudColor(msg.hudColor || Config.HudColor || 'purple');
                break;
            case 'hide':
                container.classList.remove('visible');
                container.classList.remove('dead');
                container.classList.remove('in-vehicle');
                setHealth(100);
                setArmour(0);
                setFood(100);
                setThirst(100);
                setMic('muted');
                setVehicleData({ show: false });
                break;
        }
    });

    log('EventListener de mensajes registrado correctamente.');
})();
