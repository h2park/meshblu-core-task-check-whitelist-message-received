http = require 'http'
CheckWhitelistMessageReceived = require '../'

describe 'CheckWhitelistMessageReceived', ->
  beforeEach ->
    @whitelistManager =
      checkMessageReceived: sinon.stub()

    @sut = new CheckWhitelistMessageReceived
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with a toUuid that does not match the auth.uuid', ->
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
            toUuid: 'dim-green'
            fromUuid: 'beagle'
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

      it 'should get have the status code of 422', ->
        expect(@response.metadata.code).to.equal 422

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[422]

    describe 'when called with a valid job without a to', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            fromUuid: 'bright-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the status code of 422', ->
        expect(@response.metadata.code).to.equal 422

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[422]

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'dim-green'
            fromUuid: 'hot-yallow'
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
            toUuid: 'puke-green'
            fromUuid: 'purlple-blue'
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
            toUuid: 'puke-green'
            fromUuid: 'green-bomb'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@response.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[500]
