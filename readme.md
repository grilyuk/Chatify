Поддержка iPhone<br />
Ориентация только портрет<br />
Deployment Target - iOS 14.0<br />

Для логирования state'ов использовал метод .applicationState, в каждом методе жизненного цикла.

Отключение логирования происходит за счет смены Build Configuration через Edit Scheme, в состоянии Release логирование не происходит.
