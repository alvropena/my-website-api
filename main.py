from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import traceback
from openai import OpenAI

app = FastAPI()

client = OpenAI()

# Ensure CORS middleware is set up correctly
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins for localhost:3000
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


@app.post("/generate-question/")
async def generate_question(request: Request):
    try:
        body = await request.json()
        messages = body["messages"]
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages
        )
        return response.choices[0].message.content
    except Exception as e:
        traceback_str = traceback.format_exc()
        print(traceback_str)  # Log the full traceback
        return JSONResponse(status_code=500, content={"detail": "An error occurred", "error": str(e)})


@app.post("/evaluate-answer/")
async def evaluate_response(request: Request):
    try:
        body = await request.json()
        messages = body["messages"]
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages
        )
        return response.choices[0].message.content
    except Exception as e:
        traceback_str = traceback.format_exc()
        print(traceback_str)  # Log the full traceback
        return JSONResponse(status_code=500, content={"detail": "An error occurred", "error": str(e)})
