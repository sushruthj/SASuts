import dialogflow
from flask import Flask, request
from pymessenger.bot import Bot

app = Flask(__name__)

ACCESS_TOKEN = "EAAfDNgAl5TUBAHgXOGIo8loadbKxqNuZCiZCJbOznf7bWbDEp4vNTi2LGDC4zJ4TgFfTFkMH0LGACY5uoaojX8dZCTRbrLuxf4JQMTZAzGLxiFsMflrvkIIPPoG2YCvvREZB0leOL1H866JLc3EHDB6ENe2fbZAIrJGO6lizH5ZBtMZAT6tGUJtY"
VERIFY_TOKEN = "tokentakenyo"
bot = Bot(ACCESS_TOKEN)


@app.route("/", methods=['GET', 'POST'])
def hello():
    if request.method == 'GET':
        if request.args.get("hub.verify_token") == VERIFY_TOKEN:
            return request.args.get("hub.challenge")
        else:
            return 'Invalid verification token'

    if request.method == 'POST':
        output = request.get_json()
        for event in output['entry']:
            messaging = event['messaging']
            for x in messaging:
                if x.get('message'):
                    recipient_id = x['sender']['id']
                    if x['message'].get('text'):
                        message = x['message']['text']
                        bot.send_text_message(recipient_id, message)
                    if x['message'].get('attachments'):
                        for att in x['message'].get('attachments'):
                            bot.send_attachment_url(recipient_id, att['type'], att['payload']['url'])
                else:
                    pass
        return "Success"


if __name__ == "__main__":
    app.run(port=5000, debug=True)
