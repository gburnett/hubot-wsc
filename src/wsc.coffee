# Description:
#   Get WSC Questions and Answers with proof texts
#
# Dependencies:
#   none
#
# Configuration:
#   None
#
# Commands:
#   hubot wsc list - lists each question with its number
#   hubot wsc q <question_number> - Shows the specified question
#   hubot wsc a <question_number> - Shows the answer to the specified question
#   hubot wsc qa <question_number> - Shows the specified question and answer
#   hubot wsc full <question_number> - Shows the question, answer, and proof texts of the specified question
#   hubot wsc random - gets a random question and answer with proof text
#
# Author:
#   sircharleswatson

wscQuestions = require("../lib/questions")

module.exports = (robot) ->

  robot.respond /wsc list/im, (msg) ->
    questions = wscQuestions().map((val, index) ->
      """
      **Q#{val.number} - #{val.question}**
      """
    )

    chunkedQuestions = []
    while(questions.length)
      chunkedQuestions.push(questions.splice(0, 30));

    sendChunks(msg, chunkedQuestions)

  robot.respond /wsc q ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    questions = wscQuestions()
    question = findByNumber(questions, msg.match[1])

    msg.send "**#{question.question}**"

  robot.respond /wsc a ([1-9]$|[1-9]\d$|10[0-7]$)/igm, (msg) ->
    questions = wscQuestions()
    question = findByNumber(questions, msg.match[1])

    msg.send "#{question.answer}"

  robot.respond /wsc qa ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    questions = wscQuestions()
    question = findByNumber(questions, msg.match[1])

    msg.send """
    **#{question.question}**

    #{question.answer}
    """

  robot.respond /wsc proof ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    questions = wscQuestions()
    q = findByNumber(questions, msg.match[1])
    proofs = q.proofTexts
    proof = ""
    
    for own key, value of proofs
      proof += """
      **#{key}:**

      """

      texts = value.join "\n    "
      texts = "    " + texts + "\n\n"

      proof += texts

    msg.send proof

  robot.respond /wsc full ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    number = msg.match[1]
    qa = getQuestionAndAnswer(number)
    proofs = getQuestionProofs(number)

    msg.send """
    #{qa}

    #{proofs}
    """

  robot.respond /wsc random/im, (msg) ->
    questions = wscQuestions()
    question = questions[Math.floor(Math.random() * questions.length)]

    qa = getQuestionAndAnswer(question.number)
    proofs = getQuestionProofs(question.number)

    msg.send """
    **#{question.number}.** #{qa}

    #{proofs}
    """

getQuestionAndAnswer = (number) ->
  questions = wscQuestions()
  question = findByNumber(questions, number)

  return """
  **#{question.question}**

  #{question.answer}
  """

getQuestionProofs = (number) ->
  questions = wscQuestions()
  q = findByNumber(questions, number)
  proofs = q.proofTexts
  proof = ""
  
  for own key, value of proofs
    proof += """
    **#{key}:**

    """

    texts = value.join "\n    "
    texts = "    " + texts + "\n\n"

    proof += texts

  return proof

sendChunks = (msg, chunks) ->
  setTimeout(() ->
    chunk = chunks.shift()
    if chunk == undefined
      return
    else
      msg.send chunk.join("\n")
      sendChunks(msg, chunks)
  , 250)

findByNumber = (source, number) ->
  return source.filter((obj) ->
    return +obj.number == +number;
  )[0];
