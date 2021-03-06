MessageWebhook = require '../../lib/MessageWebhook'

describe 'MessageWebhook', ->
  beforeEach ->
    @device = {}
    @request = sinon.stub()
    @generateAndStoreToken = sinon.stub()
    @revokeToken = sinon.stub()
    @dependencies = request: @request, generateAndStoreToken: @generateAndStoreToken, revokeToken: @revokeToken

  describe '->send', ->
    describe 'when instantiated with a url', ->
      describe 'when request fails', ->
        beforeEach ->
          @request.yields new Error
          @sut = new MessageWebhook @device, url: 'http://google.com', @dependencies
          @sut.send foo: 'bar', (@error) =>

        it 'should call request with whatever I want', ->
          expect(@request).to.have.been.calledWith url: 'http://google.com', json: {foo: 'bar'}

        it 'should get error', ->
          expect(@error).to.exist

      describe 'when request do not fails, but returns error that shouldnt happen', ->
        beforeEach ->
          @request.yields null, {statusCode: 103}, 'dont PUT that there'
          @sut = new MessageWebhook @device, url: 'http://google.com', @dependencies
          @sut.send foo: 'bar', (@error) =>

        it 'should call request with whatever I want', ->
          expect(@request).to.have.been.calledWith url: 'http://google.com', json: {foo: 'bar'}

        it 'should get error', ->
          expect(@error).to.exist
          expect(@error.message).to.deep.equal 'HTTP Status: 103'

      describe 'when request do fails and it mah fault', ->
        beforeEach ->
          @request.yields null, {statusCode: 429}, 'chillax broham'
          @sut = new MessageWebhook @device, url: 'http://google.com', @dependencies
          @sut.send foo: 'bar', (@error) =>

        it 'should call request with whatever I want', ->
          expect(@request).to.have.been.calledWith url: 'http://google.com', json: {foo: 'bar'}

        it 'should get error', ->
          expect(@error).to.exist
          expect(@error.message).to.deep.equal 'HTTP Status: 429'

      describe 'when request do fails and it yo fault', ->
        beforeEach ->
          @request.yields null, {statusCode: 506}, 'pay me mo moneys'
          @sut = new MessageWebhook @device, url: 'http://google.com', @dependencies
          @sut.send foo: 'bar', (@error) =>

        it 'should call request with whatever I want', ->
          expect(@request).to.have.been.calledWith url: 'http://google.com', json: {foo: 'bar'}

        it 'should get error', ->
          expect(@error).to.exist
          expect(@error.message).to.deep.equal 'HTTP Status: 506'

      describe 'when request dont fails', ->
        beforeEach ->
          @request.yields null, statusCode: 200, 'nothing wrong'
          @hook = url: 'http://facebook.com'
          @sut = new MessageWebhook @device, @hook, @dependencies
          @sut.send czar: 'foo', (@error) =>

        it 'should get not error', ->
          expect(@error).not.to.exist

        it 'should call request with whatever else I want', ->
          expect(@request).to.have.been.calledWith url: 'http://facebook.com', json: {czar: 'foo'}

        it 'should not mutate my webhook', ->
          expect(@hook).to.deep.equal url: 'http://facebook.com'

      describe 'when using a crazy scheme to get meshblu credentials forwarded', ->
        beforeEach ->
          @request.yields null, statusCode: 200, 'nothing wrong'
          @hook = url: 'http://facebook.com', generateAndForwardMeshbluCredentials: true
          @device = uuid: 'test'
          @sut = new MessageWebhook @device, @hook, @dependencies
          @sut.generateAndForwardMeshbluCredentials = sinon.stub().yields null, 'gobbledegook'
          @sut.send czar: 'foo', (@error) =>

        it 'should get not error', ->
          expect(@error).not.to.exist

        it 'should call request and add my auth', ->
          expect(@request).to.have.been.calledWith url: 'http://facebook.com', json: {czar: 'foo'}, auth: {bearer: 'dGVzdDpnb2JibGVkZWdvb2s='}

      describe 'when using a crazy scheme to get meshblu credentials forwarded but I already put in my own auth', ->
        beforeEach ->
          @request.yields null, statusCode: 200, 'nothing wrong'
          @hook = url: 'http://facebook.com', generateAndForwardMeshbluCredentials: true, auth: 'basic'
          @sut = new MessageWebhook @device, @hook, @dependencies
          @sut.generateAndForwardMeshbluCredentials = sinon.stub().yields null
          @sut.send czar: 'foo', (@error) =>

        it 'should get not error', ->
          expect(@error).not.to.exist

        it 'should call generateAndForwardMeshbluCredentials', ->
          expect(@sut.generateAndForwardMeshbluCredentials).to.have.been.called

        it 'should not override my auth', ->
          expect(@request).to.have.been.calledWith url: 'http://facebook.com', json: {czar: 'foo'}, auth: 'basic'

  describe '->generateAndForwardMeshbluCredentials', ->
    describe 'when using a crazy scheme to get meshblu credentials forwarded', ->
      beforeEach ->
        @request.yields null, statusCode: 200, 'nothing wrong'
        @hook = url: 'http://facebook.com', generateAndForwardMeshbluCredentials: true
        @device = uuid: 'test'
        @sut = new MessageWebhook @device, @hook, @dependencies
        @generateAndStoreToken.yields null, token: 'gobbledegook'
        @sut.generateAndForwardMeshbluCredentials (@error, @token) =>

      it 'should get not error', ->
        expect(@error).not.to.exist

      it 'should yield a token', ->
        expect(@token).to.deep.equal 'gobbledegook'

  describe '->removeToken', ->
    describe 'when using a crazy scheme to get meshblu credentials forwarded', ->
      beforeEach ->
        @hook = url: 'http://facebook.com', generateAndForwardMeshbluCredentials: true
        @device = uuid: 'test'
        @sut = new MessageWebhook @device, @hook, @dependencies
        @revokeToken.yields null
        @sut.removeToken 'test', (@error) =>

      it 'should get not error', ->
        expect(@error).not.to.exist

      it 'should call revokeToken', ->
        expect(@revokeToken).to.have.been.calledWith @device, @device.uuid, 'test'
