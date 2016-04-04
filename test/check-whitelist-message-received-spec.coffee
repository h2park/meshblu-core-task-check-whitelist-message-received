http = require 'http'
CheckWhitelistMessageReceived = require '../'

describe 'CheckWhitelistMessageReceived', ->
  beforeEach ->
    @whitelistManager =
      checkMessageReceived: sinon.stub()

    @sut = new CheckWhitelistMessageReceived
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with a fromUuid that does not match the auth.uuid', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'orange'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job without a from', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkMessageReceived).to.have.been.calledWith
          emitter: 'green-blue'
          subscriber: 'bright-green'

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'hot-yellow'
            fromUuid: 'dim-green'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'super-purple'
            fromUuid: 'puke-green'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkMessageReceived yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'green-bomb'
            fromUuid: 'puke-green'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@response.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[500]
