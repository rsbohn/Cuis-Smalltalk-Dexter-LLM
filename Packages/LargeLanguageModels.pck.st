'From Cuis7.1 [latest update: #6367] on 25 May 2024 at 12:21:24 pm'!
'Description '!
!provides: 'LargeLanguageModels' 1 12!
!requires: 'Cuis-Base' 71 6367 nil!
!requires: 'WebClient' 1 34 nil!
!requires: 'JSON' 1 26 nil!
SystemOrganization addCategory: #LargeLanguageModels!


!classDefinition: #CodeAssistant category: #LargeLanguageModels!
Object subclass: #CodeAssistant
	instanceVariableNames: ''
	classVariableNames: 'Keys'
	poolDictionaries: ''
	category: 'LargeLanguageModels'!
!classDefinition: 'CodeAssistant class' category: #LargeLanguageModels!
CodeAssistant class
	instanceVariableNames: ''!

!classDefinition: #LLM category: #LargeLanguageModels!
Object subclass: #LLM
	instanceVariableNames: ''
	classVariableNames: 'ApplicationKey'
	poolDictionaries: ''
	category: 'LargeLanguageModels'!
!classDefinition: 'LLM class' category: #LargeLanguageModels!
LLM class
	instanceVariableNames: ''!

!classDefinition: #AnthropicClaude category: #LargeLanguageModels!
LLM subclass: #AnthropicClaude
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'LargeLanguageModels'!
!classDefinition: 'AnthropicClaude class' category: #LargeLanguageModels!
AnthropicClaude class
	instanceVariableNames: ''!


!CodeAssistant commentStamp: '<historical>' prior: 0!
I can write code, explain concepts, and review code. Created with help from Claude 3 Haiku.

1. Define a Smalltalk class (e.g., "CodeAssistant") that encapsulates the functionality 
to handle the different use cases.
2. Implement instance methods within the CodeAssistant class to handle the respective use cases:
   - For the coding task implementation, the class could have a method named "implementCodingTask:" that takes the task description as an argument and returns the implemented code.
   - For the explanation of concepts or procedures, the class could have a method named "explainConcept:" that takes the concept description as an argument and returns the explanation.
   - For the code review, the class could have a method named "reviewCode:" that takes the code block as an argument and returns the analysis.
3. The user interaction could be facilitated through a Smalltalk workspace or a dedicated user interface, where the user can invoke the appropriate methods on an instance of the CodeAssistant class.!

!LLM commentStamp: '<historical>' prior: 0!
Holds the API key for Large Language Models
Subclass to implement the API.!

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/25/2024 11:38:03'!
explain: prompt
	"Explain <<prompt>> to the user."

	prompt ifNil: [ ^ 'I can''t explain nil.' ].
	^ self invokeClaude: prompt system: 'Give a brief explanation in an <answer> block.'! !

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/19/2024 06:54:27'!
implement: prompt
	"Returns code to implement user request."

	
	^ self invokeClaude:  prompt
		system: 'Implement the code as requested, wrapped in a code fence.'! !

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/19/2024 07:39:00'!
invokeClaude: prompt system: systemPrompt
	"compose messages, send to Claude, return the result"

	^ (AnthropicClaude new) invoke: prompt system: systemPrompt! !

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/25/2024 05:17:36'!
review: userCode
	"Review the user code."

	| systemPrompt |
	systemPrompt := 'Review the code.',
	' Wrap your analysis in an <answer> block.',
	' Note any possible issues in the code.',
	' Provide suggestions for improvement.'.
	^ self invokeClaude: userCode system: systemPrompt! !

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/25/2024 12:14:53'!
reviewMethod: aMethodSelector
	"Review the user code."

	| systemPrompt |
	systemPrompt := 'Review the code.',
	' Wrap your analysis in an <answer> block.',
	' Note any possible issues in the code.',
	' Provide suggestions for improvement.'.
	^ AnthropicClaude new
		invoke: aMethodSelector decompileString
		system: systemPrompt! !

!CodeAssistant methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/25/2024 12:09:03'!
writeUnitTests: aMethodSelector
	"Adds the ability for a Squeak CodeAssistant to automatically generate unit tests for a given method. 
	aMethodSelector: represents the name of the method for which to generate tests."
	^ AnthropicClaude new 
		invoke: (aMethodSelector decompileString)
		system: 'Please write Smalltalk unit tests for this method.'! !

!LLM methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/25/2024 12:21:04'!
readAPIKey: filename
	"load API key from a file"

	
	^ filename asFileEntry readStreamDo: [:stream | stream content]! !

!LLM class methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/19/2024 07:34:49'!
ApplicationKey

	^ ApplicationKey! !

!LLM class methodsFor: 'as yet unclassified' stamp: 'rsbohn 5/19/2024 07:35:17'!
ApplicationKey: blob

	ApplicationKey := blob! !

!AnthropicClaude methodsFor: 'accessing' stamp: 'rsbohn 5/22/2024 03:25:17'!
invoke: prompt system: systemPrompt
"Create the message body, post to the API, return the response.
	Handle any errors.
	(AnthropicClaude new) invoke: 'explain turtles' system: 'whatever'
	(AnthropicClaude new) invoke: 'conway' system: 'gaem of ifle'
	"

	| content messages payload |	
	messages := OrderedCollection new.
	messages add: (self userMessage: prompt).
	payload := {
		#model -> 'claude-3-haiku-20240307'.
		#max_tokens -> 1536.
		"#stream -> False."
		#system -> systemPrompt.
		#messages -> messages
	} asDictionary.
	content := Json render: payload.	
	^ self post: content! !

!AnthropicClaude methodsFor: 'accessing' stamp: 'rsbohn 5/25/2024 04:50:11'!
post: content
"post to the API,
	return the response.
	Handle any errors.
	"

	| response|		
	response := WebClient new httpPost: self url 
		content: content 
		type: 'application/json' 
		do: [:request |
			request method: 'POST'.
			request addHeader: 'Accept' value: 'application/json'.
			request addHeader: 'Content-Type' value: 'application/json'.
			request addHeader: 'anthropic-version' value: '2023-06-01'.
			request addHeader: 'x-api-key' value: self class ApplicationKey.].
	
	^ (Json readFrom: response stream) content! !

!AnthropicClaude methodsFor: 'accessing' stamp: 'rsbohn 5/21/2024 05:04:16'!
url

	^ 'https://api.anthropic.com/v1/messages'! !

!AnthropicClaude methodsFor: 'converting' stamp: 'rsbohn 5/19/2024 16:54:17'!
userMessage: message
	"wrap as a user message"
	
	^ {
		#role -> 'user'.
		#content -> message
		} asDictionary.! !
