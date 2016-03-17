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
      question = "Q#{val.number} - #{val.question}"
      response = bold(question, robot.adapterName)
      """
      #{response}
      """
    )

    chunkedQuestions = []
    while(questions.length)
      chunkedQuestions.push(questions.splice(0, 30));

    sendChunks(msg, chunkedQuestions)

  robot.respond /wsc q ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    questions = wscQuestions()
    question = findByNumber(questions, msg.match[1])
    question = bold(question.question, robot.adapterName)

    msg.send "#{question}"

  robot.respond /wsc a ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    questions = wscQuestions()
    question = findByNumber(questions, msg.match[1])

    msg.send "#{question.answer}"

  robot.respond /wsc qa ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    msg.send getQuestionAndAnswer(msg.match[1], robot.adapterName)

  robot.respond /wsc proof ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    msg.send getQuestionProofs(msg.match[1], robot.adapterName)

  robot.respond /wsc full ([1-9]$|[1-9]\d$|10[0-7]$)/im, (msg) ->
    number = msg.match[1]
    qa = getQuestionAndAnswer(number, robot.adapterName)
    proofs = getQuestionProofs(number, robot.adapterName)

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
    #{bold(question.number, robot.adapterName)}. #{qa}

    #{proofs}
    """

getQuestionAndAnswer = (number, adapter) ->
  questions = wscQuestions()
  question = findByNumber(questions, number)
  boldQuestion = bold(question.question, adapter)

  return """
  #{boldQuestion}

  #{question.answer}
  """

getQuestionProofs = (number, adapter) ->
  questions = wscQuestions()
  q = findByNumber(questions, number)
  proofs = q.proofTexts
  proof = ""
  
  for own key, value of proofs
    key = "#{key}:"
    proofNumber = bold(key, adapter)

    proof += """
    #{proofNumber}

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

bold = (text, adapter) ->
  switch adapter
    when "discord"
      "**#{text}**"
    when "slack"
      "*#{text}*"
    else
      "#{text}"
