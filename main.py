from fastapi import FastAPI, HTTPException, Request
import openai
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

openai.api_key = os.getenv("OPENAI_API_KEY")


@app.post("/generate-question/")
async def generate_question(request: Request):
    try:
        body = await request.json()
        messages = body["messages"]
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages
        )
        return response.choices[0].message["content"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
