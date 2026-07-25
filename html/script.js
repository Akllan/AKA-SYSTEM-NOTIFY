(function() {
    'use strict';

    const D = (typeof Config !== 'undefined' && Config.Debug === true);
    const notifContainer = document.getElementById('notification-container');
    const root = document.documentElement;

    const NOTIF_TYPES = {
        success: { icon: 'M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z', color: '#2bff72', glow: '46, 255, 114' },
        error:   { icon: 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z', color: '#ff2b2b', glow: '255, 43, 43' },
        warning: { icon: 'M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z', color: '#f39c12', glow: '243, 156, 18' },
        info:    { icon: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z', color: '#3498db', glow: '52, 152, 219' },
        main:    { icon: 'M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z', color: '#19a3ff', glow: '25, 163, 255' },
        item:    { icon: 'M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H5.17L4 17.17V4h16v12z', color: '#b040e0', glow: '176, 64, 224' }
    };

    if (!notifContainer) {
        if (D) console.error('[aka-notify] notification-container no encontrado');
        return;
    }

    function escapeHTML(str) {
        if (typeof str !== 'string') return '';
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    const notifAudio = new Audio('assets/notif.mp3');
    notifAudio.preload = 'auto';
    notifAudio.volume = 0.5;

    function playNotifSound() {
        notifAudio.currentTime = 0;
        notifAudio.play().catch(function() {});
    }

    function stopNotifSound() {
        notifAudio.pause();
        notifAudio.currentTime = 0;
    }

    var activeNotifCount = 0;

    function addNotification(label, itemLabel, type, customColor, customIcon, duration) {
        const t = NOTIF_TYPES[type] || NOTIF_TYPES.info;
        const color = customColor || t.color;
        const glow = t.glow;
        const iconPath = customIcon || t.icon;

        const toast = document.createElement('div');
        toast.className = 'notification-toast';
        toast.style.setProperty('--notif-color', color);
        toast.style.setProperty('--notif-color-rgb', glow);

        const iconHTML = '<div class="notif-icon"><svg class="notif-svg" viewBox="0 0 24 24" width="18" height="18"><path d="' + iconPath + '"/></svg></div>';
        toast.innerHTML = iconHTML + '<div class="notif-text"><span class="notif-action">' + escapeHTML(label) + '</span><span class="notif-item">' + escapeHTML(itemLabel) + '</span></div>';

        if (type === 'error') toast.classList.add('notif-error');

        notifContainer.prepend(toast);
        void toast.offsetHeight;
        toast.classList.add('enter');

        activeNotifCount++;
        playNotifSound();

        setTimeout(function() {
            toast.classList.remove('enter');
            toast.classList.add('exit');
            setTimeout(function() {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
                activeNotifCount--;
                if (activeNotifCount <= 0) stopNotifSound();
            }, 400);
        }, duration || 3000);
    }

    window.addEventListener('message', function(event) {
        const msg = event.data;
        if (!msg || msg.action !== 'notification') return;
        addNotification(msg.label, msg.itemLabel, msg.type, msg.color, msg.icon, msg.duration);
    });

    if (D) console.log('[aka-notify] Notification system initialized');
})();
