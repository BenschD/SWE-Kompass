package com.example.bearing.api;

/**
 * Semantische Validierungsfehler ({@code /LF230/}, {@code /LF240/}). Als {@link RuntimeException}, damit Host-Code
 * nicht zwingend deklarieren muss (optional weiter mit try/catch behandelbar).
 */
public final class ValidationException extends RuntimeException {

    private final ErrorCode errorCode;

    /**
     * @param errorCode maschinenlesbarer Code
     * @param message   Beschreibung
     */
    public ValidationException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public ErrorCode errorCode() {
        return errorCode;
    }
}
