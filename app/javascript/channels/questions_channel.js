import consumer from './consumer'

function initializeQuestionsChannel() {
    const subroutes = location.pathname.split('/');
    if (subroutes.length !== 2) {
        return;
    }

    if (subroutes[0] !== 'content') {
        return;
    }

    const content_id = subroutes[1];
    consumer.subscriptions.create({channel: 'QuestionsChannel', content_id: content_id}, {
        received: function (data) {
            location.reload();
        }
    })
}

initializeQuestionsChannel();
