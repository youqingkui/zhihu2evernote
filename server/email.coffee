nodemailer = require('nodemailer')

module.exports = () ->

  transporter = nodemailer.createTransport
    service: 'QQex'
    auth:
      user: process.env.EMAIL_NAME
      pass: process.env.EMAIL_PWD


  send:(body, to='youqingkui@qq.com', subj='hi') ->
    transporter.sendMail
      from: 'yuankui@mykar.com'
      to: to
      subject: subj
      html: body
      generateTextFromHtml: true

    ,(err, info) ->
      return console.log err if err

      console.log info