
  const {AutoLanguageClient} = require('atom-languageclient')
  const cp = require('child_process')
  const debug = true


  class oberon0LanguageClient extends AutoLanguageClient {
    getGrammarScopes () { return [ 'oberon0' ] }
    getLanguageName () { return 'oberon0' }
    getServerName () { return 'oberon0-LanguageServer' }

    startServerProcess () {
      const command = "java"
      const args = ["-jar", "/Users/joeblanchard/MELT/silver-ide//generated/LSPServers/oberon0-lspLanguageServer/target/oberon0-lsp-1.0.jar"]
      const childProcess = cp.spawn(command, args)
      this.captureServerErrors(childProcess)
      if (debug) {
        console.log("Started child process")
      }
      childProcess.on('close', exitCode => {
        if (!childProcess.killed) {
        atom.notifications.addError('oberon0-LanguageServer stopped unexpectedly.', {
          dismissable: true,
          description: this.processStdErr ? "<code> + "this.processStdErr + "</code>" : "Exit code: " + exitCode
        })
      }
    })
    return childProcess
  }

    //shouldStartForEditor() {
    //  // figure out good way to start this (proejct file?)
    //  use default for now which is if any file is open in the editor
    //}
  }

  module.exports = new oberon0LanguageClient()
  